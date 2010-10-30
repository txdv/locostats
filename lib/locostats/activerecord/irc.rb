require 'locostats/activerecord/default'

module PsychoStats::Site

  class User

    # creates a user and associates it with the profile
    # sets the profile irc value to username, which should be the nickname in irc
    def self.create_irc(username, password, profile)
      
      user = User.create(
        :username => username,
        :password => Digest::MD5.hexdigest(password),
        :confirmed => 1,
        :accesslevel => 2
      )

      profile.userid = user.id
      profile.irc = username
      profile.save!
      return user
    rescue
      nil
    end

  end
  
  module Irc

    class Migration < ActiveRecord::Migration
      def self.up
        add_column PsychoStats::Site::Profile.table_name, :irc, :string
      end

      def self.down
        remove_column PsychoStats::Site::Profile.table_name, :irc
      end
    end

  end

end
