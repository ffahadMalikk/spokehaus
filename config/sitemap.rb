SitemapGenerator::Sitemap.default_host = "https://spokehaus.ca"
SitemapGenerator::Sitemap.create do
  add '/ride'
  add '/experience'
  add '/calendar', changefreq: 'daily'
  add '/privacy-policy'
  add '/terms-and-conditions'
  add '/packages'
end
