require 'locostats/activerecord/default'

module PsychoStats::Site

  module Amxmodx

    class Migration < ActiveRecord::Migration

      def self.up
        add_column PsychoStats::Site::User.table_name, :auth, :string
        add_column PsychoStats::Site::User.table_name, :access, :string
        add_column PsychoStats::Site::User.table_name, :flags, :string
      end

      def self.down
        remove_columns PsychoStats::Site::User.table_name, :auth, :access, :flags
      end

      def self.update
        uniqueid = PsychoStats::Config::
          Variable.find_by_sql("SELECT value FROM #{PsychoStats.prefix + "config"} WHERE var = 'uniqueid'").first.value.to_sym

        case uniqueid
        when :worldid
          users = User.find(:all).each do |user|
            if user.auth.nil?
              user.auth = user.player.uniqueid
              user.access = "z" # user, no admin
              user.flags = "c" # steamid
              user.save!
            end
          end
        end
      end

    def self.load_file(file, overwrite = false)
      f = File.open(file)
      load(f.read, overwrite)
      f.close
    end

    def self.load(string_block, overwrite = false)
      string_block.each_line do |line|
        if !(line =~ /(^;)/)
          if line =~ /\"(.+)\"\s+\"(|.+)\"\s+\"(.+)\"\s+\"(.+)\"/
            load_admin($1, $3, $4, overwrite)
          end
        end
      end
    end

    def self.load_admin(uniqueid, access, flags, overwrite = false)
      player = PsychoStats::GameStats::Player.search(uniqueid)
      return if player.nil?

      user = player.user
      return if user.nil?

      if user.auth.nil? or overwrite
        user.auth = player.uniqueid
        user.access = access
        user.flags = flags
        user.save!
        puts "Loaded #{user.username}(#{player.uniqueid}) with \"#{access}\" \"#{flags}\""
      end

    end

  end

  end

  class User
    def add_access_flags(aflags)
      access = (access.split("") + aflags.split("")).uniq.join
      save!

    end
    def del_access_flags(aflags)
      flags = flags.gsub(aflags, "")
      save!
    end
    
    def add_connection_flags(cflags)
      flags = (flags.split("") + cflags.split("")).uniq.join
      save!
    end
    def del_connection_flags(cflags)
      flags = flags.gsub(aflags, "")
      save!
    end


  end

end