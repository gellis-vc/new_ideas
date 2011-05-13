puts "Loading proper names..."

@names = []
File.open('/usr/share/dict/propernames').each_line { |name| @names << name }

puts "Loading postal codes..."

@codes = PostalCode.find :all
raise 'No postal codes found. Run "rake db:seed" to load seed data.' if @codes.empty?

# puts "Wiping existing data..."
# 
# Vote.destroy_all
# Tag.destroy_all
# Comment.destroy_all
# Idea.destroy_all
# User.destroy_all :admin => false

puts "Creating users..."

@users = (1..20).map do |i|
  user = User.create!(
    :name => @names.rand.strip,
    :email => "#{i}@demo.user",
    :password => "pass#{i}",
    :password_confirmation => "pass#{i}",
    :zip_code => @codes.rand.code,
    :terms_of_service => '1')
  user.activate!
  user
end

puts "Creating ideas..."

def create_idea(factor, title, desc)
  tags = Tag.from_string(
    title.gsub(/[^a-zA-Z]/, ' ').gsub(/(\s|^)(a|an|the|to|from|for|when|it|of|are)(\s|$)/i, ' ').gsub(/\s+/,','))
  Idea.create!(
    :inventor => @users.rand,
    :title => title,
    :description => desc,
    :rating => (factor / (rand ** 2.5 * 100 + 1)).round + 1,
    :tags => tags)
end

1.times do |i|
  f = 100 / (i+1)
  create_idea f, "Have \"buy 10 get one free\" punch cards for CDs",
                 "It could be an online card or a physical card or whatever."
  create_idea f, "Feature CDs by local musicians",
                 "Seriously, get more local! There are great musicians everywhere. They bring in customers and deserve Best Buy's support."
  create_idea f, "Get rid of those stupid plastic boxes that are way too hard to open",
                 "&*$^*&^$ they are irritating! Boxes should be easy to open, and not require a welding torch and a chainsaw to open!! Refuse to sell products with these boxes!"
  create_idea f, "Makes cables a lot cheaper",
                 "Seriously. They are ridiculous."
  create_idea f, "Provide a better acoustically isolated room for listening to speakers",
                 "The stores are just too NOISY. How about some peace & quiet for listening to equipment?"
  create_idea f, "Give away sampler CDs with current top hits when you buy a regular CD",
                 "I want to discover more new music."
  create_idea f, "Give more time to return defective items",
                 "Sometimes you don't know it's defective right away."
  create_idea f, "Charge less!",
                 "bad economic times = more sales, please"
  create_idea f, "Host listening parties when new CDs are released",
                 "Have a little party in the store. Maybe give out a code for a free download from the CD or something?"
  create_idea f, "Sell microphones",
                 "I know you're not guitar center, but what about some basic home recording equipment?"
  create_idea f, "Sell solid-state drives",
                 "Their time has come. Silent, fast, cheaper by the day!"
  create_idea f, "Use less packaging",
                 "There's a LOT of waste at Best Buy. How about using less packing for everything? Follow Apple's lead."
  create_idea f, "Have in-store demos of iPhone apps",
                 "The App Store doesn't have a demo facility. How about demos in store?"
  create_idea f, "Have parking on top of stores",
                 "Box stores take up way too much land! How about letting people park on the roof? I don't want my city to become all pavement."
  create_idea f, "Reward Zone should go paperless",
                 "No more mailing! You have an account, you can check it online, and it's always there at the store."
  create_idea f, "Sell generic Mini DisplayPort to DVI/VGA/HDMI adapters",
                 "These things are like $30 from the Apple Store. That's ridiculous! You could sell them for $20 and it would still be a ridiculous margin, and people would flock to it."
  create_idea f, "Have cold/hot weather sales",
                 "How about 1% off for every degree below 10 or above 100?"
  create_idea f, "Have a dark area for viewing TV screens",
                 "A lot of people watch movies in the dark, and a lot of display problems are only visible in darkly lit rooms (e.g. backlight showing through in black areas). How about letting people check that out in the store?"
  create_idea f, "Sell Grado headphones",
                 "They're the best, and cheaper than a lot of the alternatives!"
  create_idea f, "More & better classical music",
                 "A lot of the classical stuff Best Buy sells is really generic and fluffly, lowest common denominator sort of stuff. Classical stuff sells well, but you have to have a good selection! Not all CDs are created equal!\n\nHire somebody to choose a really good selection for your stores, and I'll bet you'll sell more."
  create_idea f, "Daily store sweepstakes",
                 "Here's the idea: every day at each store, one customer selected at random will get their purchase free when they check out!\n\nOne entry per person per day. Imagine the draw that would have."
  create_idea f, "Get smaller, lighter security devices for mobile devices",
                 "With music players and phones and such, it's really important how small it is, how light it is, etc. But it's really hard to tell when there's this big security device stuck to it! Make them smaller so that we can see what these devices really feel like in our hands in the store."
  create_idea f, "Giftag iPhone app",
                 "I'd like to be able to pull out my iPhone when I'm out shopping, take a photo of a product, and add it to my Giftag list!"
end
