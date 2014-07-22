

task :default do

%[install]
%[test]

end

task :install do
  desc "building sqlite regex extension"
  sh 'cd sqlite-regexp-master && make'
  sh 'cp sqlite-regexp-master/regexp.o  .'
  sh 'cp sqlite-regexp-master/regexp.sqlext  .'
  
  #build sqlite regex module
  #get wkhtmlbinary
end

task :test do
  # call tests
end
