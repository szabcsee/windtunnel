  def protected!
    return if authorized?
    headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
    halt 401, "Not authorized\n"
  end
  
  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    # Hard coded admin password
    @auth.provided? and @auth.basic? and @auth.credentials and @auth.credentials == ['admin', 'password']
  end
  
  def generate_serial_number(last_id)
    time = Time.now.year.to_s  + Time.now.month.to_s + Time.now.day.to_s + Time.now.hour.to_s + Time.now.min.to_s + (last_id + 1).to_s
    serial_number = time + random_numeric(3).to_s
    
    if Card.find_by_serial_number(serial_number)
      serial_number = time + random_numeric(3).to_s
    end
    
    return serial_number
  end  
  
  def random_numeric(size)
    random_number = size.times.map{ 1 + Random.rand(9)}
    random_number = random_number.to_s
    random_number = random_number.gsub(' ','').gsub('[','').gsub(']','').gsub('"','').gsub(',','')
    return random_number
  end
  
  def expiry_date
    time = Time.now + 6.months
    return time
  end