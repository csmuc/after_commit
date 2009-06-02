Gem::Specification.new do |s|
  s.name = 'after_commit'
  s.version = '0.9.0'
  s.date = '2009-06-02'
  
  s.summary = "Threadsafe after_commit callbacks for ActiveRecord models"
  s.description = "Threadsafe after_commit callbacks for ActiveRecord models."
  
  s.authors = ['Christian Seiler']
  s.email = 'chr.seiler@gmail.com'
  s.homepage = 'http://github.com/mislav/will_paginate/wikis'
  
  s.has_rdoc = false
  #s.rdoc_options = ['--main', 'README.rdoc']
  #s.rdoc_options << '--inline-source' << '--charset=UTF-8'
  #s.extra_rdoc_files = ['README.rdoc', 'LICENSE', 'CHANGELOG']
  # s.add_dependency 'actionpack', ['>= 1.13.6']
  
  s.files = %w(README test/after_commit_test.rb lib/after_commit.rb)
  s.test_files = %w(test/after_commit_test.rb)
end