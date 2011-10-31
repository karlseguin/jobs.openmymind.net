builder do |xml|
   xml.instruct! :xml, :version => '1.0'
   xml.rss :version => "2.0" do
     xml.channel do
       xml.title "Liftoff News"
       xml.description "Liftoff to Space Exploration."
       xml.link "http://liftoff.msfc.nasa.gov/"

       @jobs.each do |job|
         xml.item do
           xml.title job['title']
           xml.link job['url']
           xml.description job['description']
           xml.pubDate job['created_at'].rfc822()
           xml.guid job['url']
         end
       end
     end
   end
 end