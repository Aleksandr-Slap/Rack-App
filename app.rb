require 'rack'
require 'byebug'

class App

  def call(env)
    @env = env
    @params = @env["QUERY_STRING"]
    format unless @params&.nil?
    [status, headers, body]
  end

  private

  PARAMS_VALID = "%y%m%d%h%m%s".freeze

  def format
    @newparams = []
    @badparams = []
    i = 7
    while i < @params.length
      @newparams.push(@params[i]) if PARAMS_VALID.include?(@params[i])
      @badparams.push(@params[i]) unless PARAMS_VALID.include?(@params[i])
      i += 1
    end 
  end

  def status
    @env["REQUEST_PATH"] == "/time"? 200 : 404 and @badparams.empty? ? 200 : 400
  end
  
  def headers
    @newparams.clear if @badparams&.any?
    if status_200 && @newparams&.any?
      { "The-date-time" => "#{Time.now.strftime(@newparams.join("-"))}" }
    elsif status_200
      { "The-date-time" => "#{Time.now}" }
    else  
      {'Error' => "Invalid request"}
    end 
  end
  
  def body
    if status_200
      ["Welcome aboard!\n"]
    elsif status == 400
      ["Unknown time format #{@badparams}\n"]
    else
      ["Try again!\n"]
    end
  end

  def status_200
    status == 200
  end
end