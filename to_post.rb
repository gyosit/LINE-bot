require "net/http"

Net::HTTP.version_1_2
http = Net::HTTP.new("gettw.herokuapp.com",443)
http.use_ssl = true
response = http.post('/send','msg=MESSAGE')
