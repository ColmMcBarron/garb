module Garb
  module Management
    class Profile

      include ProfileReports

      attr_reader :session, :path
      attr_reader :id, :title, :account_id, :web_property_id

      def self.all(session = Session, path = '/accounts/~all/webproperties/~all/profiles')
        feed = Feed.new(session, path)
        feed.entries.map {|entry| new(entry, session)}
      end

      def self.for_account(account)
        all(account.session, account.path+'/webproperties/~all/profiles')
      end

      def self.for_web_property(web_property)
        all(web_property.session, web_property.path+'/profiles')
      end

      def initialize(entry, session)
        @session = session
        @path = Garb.parse_link(entry, "self").gsub(Feed::BASE_URL, '')
        @title = entry['title'].gsub('Google Analytics Profile ', '')

        properties = Garb.parse_properties(entry)
        @id = properties['profile_id']
        @account_id = properties['account_id']
        @web_property_id = properties['web_property_id']
      end

      # def path
      #   ['/accounts', self.account_id, 'webproperties', self.web_property_id, 'profiles', self.id].join('/')
      # end

      # def goals
      # end
    end
  end
end