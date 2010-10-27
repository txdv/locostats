require 'active_record'

module PsychoStats

  @table_names = nil

  def self.prefix(pre)

    if @table_names.nil?
      @table_names = {}
      constants.each do |const|
        klass = const_get(const)
        @table_names[const] = klass.table_name
      end
    end

    constants.each do |const|
      klass = const_get(const)
      if (klass.superclass == ActiveRecord::Base)
        klass.set_table_name pre + @table_names[const]
      end
    end
  end

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

    has_one :profile, :class_name => "Profile", :foreign_key => :uniqueid

    has_many :sessions, :class_name => "Session", :foreign_key => :plrid

    has_many :victims, :class_name => "Victinm", :foreign_key => :plrid
    has_many :weapondata, :class_name => "PlayerWeapon", :foreign_key => :plrid

    def self.total_ranked
      self.find(:all, :select => "COUNT(*) AS total", :conditions => "allowrank = 1").first.total.to_i
    end

    def kills; data.sum('kills'); end

    def deaths; data.sum('deaths'); end
  end

  class Profile < ActiveRecord::Base
    set_table_name "plr_profile"
    set_primary_key :uniqueid
  end

  class Session < ActiveRecord::Base
    set_table_name "plr_session"
    set_primary_key :dataid
  end
  
  class Victims < ActiveRecord::Base
    set_table_name "plr_session"
    set_primary_key :dataid

  end

  class PlayerWeapon < ActiveRecord::Base
    set_table_name "plr_weapons"
    set_primary_key :dataid

    has_one :weapon, :class_name => "Weapon", :foreign_key => :weaponid
  end

  class Weapon < ActiveRecord::Base
    set_table_name "weapon"
    set_primary_key :weaponid

    has_many :dataset, :class_name => "WeaponData", :foreign_key => :weaponid
  end

  class WeaponData < ActiveRecord::Base
    set_table_name "plr_weapons"
    set_primary_key :dataid
  end

  class Clan < ActiveRecord::Base
    set_table_name "clan"
    set_primary_key :clantag
    
    has_one :profile, :class_name => "ClanProfile", :foreign_key => :clantag
  end

  class ClanProfile < ActiveRecord::Base
    set_table_name "clan_profile"
    set_primary_key :clantag
  end

  class ConfigVariable < ActiveRecord::Base
    set_table_name "config"
    set_primary_key :id
  end

end
