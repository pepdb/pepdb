# pepDB

This is the code behind http://pepdb.zbh.uni-hamburg.de

### Overview 

You can use pepDB to store and analyse NGS peptide datasets. Additionally you'll have access to various browsing and search functions.


In order to get this running on your own linux system you'll need:

* Ruby >= 1.9.3
* SQLite
* Bundler

To setup everything needed to use pepDB, type 

```
% bundle install && bundle exec rake install
% ruby app.rb
```

If everything was successful you can reach the site via http://localhost:4567 and log in with<br> 
`user: admin pw: adminpw`

If you want to use pepDB with some example data, run:

```
% rake example
```

To serve pepDB via apache have a look at the [passenger documentation](https://www.phusionpassenger.com/documentation/Users%20guide%20Apache.html#_deploying_a_rack_based_ruby_application_including_rails_gt_3).
