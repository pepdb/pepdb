require 'securerandom'

task :default do

%[install]
%[test]

end

task :install do
  desc "building sqlite regex extension"
  sh 'cd sqlite-regexp-master && make'
  sh 'cp sqlite-regexp-master/regexp.o  .'
  sh 'cp sqlite-regexp-master/regexp.sqlext  .'
  
  desc "setting up session cookie"

  sh %Q/echo "use Rack::Session::Cookie, :expire_after => 3600, :secret => '#{SecureRandom.hex(32)}'" >> session_cookie.rb/

end

task :test do
  # call tests
end
