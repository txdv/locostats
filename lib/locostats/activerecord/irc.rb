require 'locostats/activerecord/default'

module PsychoStats::Site
  
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
