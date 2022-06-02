require 'rack'
require 'byebug'

class App

  def call(env)
    @env = env
    @params = @env["QUERY_STRING"]
    sort_parameters if @params.length != 0
    [status, headers, body]
  end

  private

  PARAMS_VALID = { "year" => "%y", "month" => "%m", "day" => "%d", "hour" => "%H", "min" => "%M", "sec" => "%H" }.freeze

  def sort_parameters
    @valid_params = []
    @bad_params = []
    # byebug
    params = @params.split(%r{=\s*})[1].split(%r{%2C\s*})
    params.each do |p|
      if PARAMS_VALID[p]
        @valid_params << PARAMS_VALID[p]
      else
        @bad_params << p
      end   
    end  
  end  

  def status
    return 400 if no_bad_parameters?

    @env["REQUEST_PATH"] == "/time" ? 200 : 404
  end
  
  def headers
    return { "The-date-time" => "ERROR" } if no_bad_parameters?

    if @valid_params != nil ?  { "The-date-time" => "#{Time.now.strftime(@valid_params.join("-"))}" } : { "The-date-time" => "#{Time.now }" }
  end    

  def body
    return ["Invalid URL"] if @env["REQUEST_PATH"] != "/time"

    status == 200 ? ["Welcome aboard!\n"] : ["Unknown time format #{@bad_params}"]
  end

  def no_bad_parameters?
    return false if @bad_params == nil
    true if @bad_params.size != 0
  end  
end