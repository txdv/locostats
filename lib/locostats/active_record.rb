require 'active_record'

module PsychoStats

  @table_names = {}

  def self.prefix_obj(object, val)
    object.constants.each do |const|
      klass = object.const_get(const)
      if klass.is_a?(Class) and  klass.superclass == ActiveRecord::Base 
        if @table_names[klass.hash].nil?
          @table_names[klass.hash] = klass.table_name
        end
        klass.set_table_name val + @table_names[klass.hash]
      elsif klass.is_a?(Module)
        prefix_obj(klass, val)
      end
      #@table_names[object.hash] = klass.table_name if klass.superclass == ActiveRecord::Base
    end
  end

  def self.prefix(val)
    prefix_obj(self, val)
  end

module GameStats

  class PlayerData < ActiveRecord::Base
    set_table_name "plr_data"
    set_primary_key :dataid

    belongs_to :player, :class_name =>"Player", :foreign_key => :plrid
  end

  class WorldID < ActiveRecord::Base
    set_table_name "plr_ids_worldid"
    set_primary_key :worldid

    belongs_to :player, :class_name => "Player", :foreign_key => :plrid
  end

  class PlayerIP < ActiveRecord::Base
    set_table_name "plr_ids_ipaddr"
    set_primary_key :plrid

    belongs_to :player, :class_name => "Player", :foreign_key => :plrid

    def country
      PsychoStats::Geo::IP.find(:first, :conditions => [ "start >= ? AND ? <= end", ipaddr, ipaddr ])
    end
  end

  class PlayerName < ActiveRecord::Base
    set_table_name "plr_ids_name"
    set_primary_key :plrid

    belongs_to :player, :class_name => "Player", :foreign_key => :plrid
  end

  class Player < ActiveRecord::Base
    set_table_name "plr"
    set_primary_key :plrid

    has_many :names, :class_name => "PlayerName", :foreign_key => :plrid
    has_many :ips, :class_name => "PlayerIP", :foreign_key => :plrid
    has_many :worldids, :class_name => "WorldID", :foreign_key => :plrid
    has_many :data, :class_name => "PlayerData", :foreign_key => :plrid

    has_one :profile, :class_name => "PsychoStats::Site::Profile", :primary_key => :uniqueid, :foreign_key => :uniqueid
    has_one :clan, :class_name => "Clan", :primary_key => :clanid, :foreign_key => :clanid

    has_many :sessions, :class_name => "Session", :foreign_key => :plrid

    has_many :victims, :class_name => "Victim", :foreign_key => :plrid
    has_many :weapons, :class_name => "PlayerWeapon", :foreign_key => :plrid

    has_many :bans, :class_name => "Ban", :foreign_key => :plrid

    def self.total_ranked
      self.find(:all, :select => "COUNT(*) AS total", :conditions => "allowrank = 1").first.total.to_i
    end

    def kills; data.sum('kills'); end

    def deaths; data.sum('deaths'); end

    def self.search(id)
      plrid = PlayerName.find_by_name(id)
      plrid = WorldID.find_by_worldid(id) if plrid.nil?
      plrid = PlayerIP.find_by_ipaddr(IPAddr.new(id).to_i) if plrid.nil?
      plrid.player
    rescue
      nil
    end
  end

  class Session < ActiveRecord::Base
    set_table_name "plr_sessions"
    set_primary_key :dataid

    has_one :map, :class_name => "Map", :primary_key => :mapid, :foreign_key => :mapid
  end
  
  class Victim < ActiveRecord::Base
    set_table_name "plr_victims"
    set_primary_key :dataid

  end

  class PlayerWeapon < ActiveRecord::Base
    set_table_name "plr_weapons"
    set_primary_key :dataid

    has_one :weapon, :class_name => "Weapon", :primary_key => :weaponid, :foreign_key => :weaponid
  end

  class Weapon < ActiveRecord::Base
    set_table_name "weapon"
    set_primary_key :weaponid

    has_many :data, :class_name => "WeaponData", :foreign_key => :weaponid
  end

  class WeaponData < ActiveRecord::Base
    set_table_name "plr_weapons"
    set_primary_key :dataid
  end

  class Clan < ActiveRecord::Base
    set_table_name "clan"
    set_primary_key :clantag
    
    has_one :profile, :class_name => "PsychoStats::Site::ClanProfile", :foreign_key => :clantag
  end

  class Ban < ActiveRecord::Base
    set_table_name "plr_bans"
  end

  class Map < ActiveRecord::Base
    set_table_name "map"
    set_primary_key :mapid

    has_one :data, :class_name => "MapData", :foreign_key => :mapid
    has_many :hourly, :class_name => "MapHourly", :foreign_key => :mapid

  end

  class MapData < ActiveRecord::Base
    set_table_name "map_data"
    set_primary_key :dataid

    has_one :cstrike, :class_name => "MapDataCounterStrike", :foreign_key => :dataid
    #has_many :hourly :class_name => "MapHourly", :foreign_key => :dataid
  end

  class MapDataCounterStrike < ActiveRecord::Base
    set_table_name "map_data_halflife_cstrike"
    set_primary_key :dataid
  end

  class MapHourly < ActiveRecord::Base
    set_table_name "map_hourly"
  end

end

module Site

  class Profile < ActiveRecord::Base
    set_table_name "plr_profile"
    set_primary_key :uniqueid

    has_one :name_info, :class_name => "PlayerName", :primary_key => :name, :foreign_key => :name

    def country
      PsychoStats::Geo::CountryCode.find_by_cc(cc).cn
    end
  end

  class ClanProfile < ActiveRecord::Base
    set_table_name "clan_profile"
    set_primary_key :clantag
  end

end

module Geo

  class IP < ActiveRecord::Base
    set_table_name "geoip_ip"
    set_primary_key [:start, :end]

    has_one :country_name, :class_name => "CountryCode", :primary_key => :cc, :foreign_key => :cc

    def name
      country_name.cn
    end

  end

  class CountryCode < ActiveRecord::Base
    set_table_name "geoip_cc"
    set_primary_key :cc
  end

end

module Config

  class Variable < ActiveRecord::Base
    set_table_name "config"
    set_primary_key :id
  end

  class Award
    set_table_name "config_awards"
    set_primary_key :id
  end

  class ClanTag
    set_table_name "config_clantgs"
    set_primary_key :id
  end

  class Event
    set_table_name "config_events"
    set_primary_key :id
  end

  class LogSoruces
    set_table_name "config_logsources"
    set_primary_key :id
  end

  class Overlays
    set_table_name "config_logsources"
    set_primary_key :id
  end

  class Bans
    set_table_name "config_plrbans"
    set_primary_key :id
  end

  class Bonuses
    set_table_name "config_plrbonuses"
    set_primary_key :id
  end

  class Servers
    set_table_name "cnofig_config_servers"
    set_primary_key :id
  end

  class Themes
    set_primary_key :id
    set_table_name "config_themes"
  end

end

end
