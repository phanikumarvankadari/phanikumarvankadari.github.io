source "https://rubygems.org"

# Core Jekyll
gem "jekyll", "~> 4.3"

# Minimal plugins
group :jekyll_plugins do
  gem "jekyll-feed"
end

# Windows and JRuby compatibility
platforms :mingw, :x64_mingw, :mswin, :jruby do
  gem "tzinfo", ">= 1", "< 3"
  gem "tzinfo-data"
end

# Performance-booster for watching directories on Windows
gem "wdm", "~> 0.1.1", :platforms => [:mingw, :x64_mingw, :mswin]