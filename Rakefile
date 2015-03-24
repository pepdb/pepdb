require 'securerandom'
require 'mkmf'
task :default do

%[install]

end

task :install do
  desc "building sqlite regex extension"
  sh 'cd sqlite-regexp-master && make'
  sh 'cp sqlite-regexp-master/regexp.o  .'
  sh 'cp sqlite-regexp-master/regexp.sqlext  .'
  
  desc "setting up session cookie"

  sh %Q/echo "use Rack::Session::Cookie, :expire_after => 3600, :secret => '#{SecureRandom.hex(32)}'" > session_cookie.rb/
end

task :example do
  desc "setup database with example data"
  if File.exists?("./pep.db")
    sh 'mv pep.db pep.db_old'
  end
  if find_executable('sqlite') || find_executable('sqlite3')
    sh 'sqlite3 pep.db < ./test/testdata/test.sql'
  else
    abort("Error: sqlite probably not installed, can't create example database.")
  end
end
