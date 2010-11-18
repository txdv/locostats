
AMX_ACCESS = {
  :a => :immunity,
  :b => :reservation,
  :c => :amx_kick,
  :d => :amx_ban,
  :e => :amx_slay,
  :f => :amx_map,
  :g => :amx_cvar,
  :h => :amx_cfg,
  :i => :amx_chat,
  :j => :amx_vote,
  :u => :menuaccess,
  :z => :user
}

AMX_ACCESS_SHORT = AMX_ACCESS.clone

AMX_ACCESS_SHORT.each { |k,v| AMX_ACCESS_SHORT[k] = AMX_ACCESS[k].to_s.gsub(/^amx_/, "").to_sym }

AMX_FLAGS = {
  :b => :clan,
  :c => :steam,
  :d => :ip,
  :e => :nopass
}


class String

  #long 
  def long_split
    self.split(" ").uniq.sort
  end

  def rights_uniq
    self.long_split.join(" ")
  end

  def long(val)
    rights = self.short_split

    rest = (rights - val.keys)
    rights = rights - rest

    (rights.collect { |c| val[c.to_sym] } + rest).join(" ")
  end

  def long_access
    long(AMX_ACCESS_SHORT)
  end

  def long_flags
    long(AMX_FLAGS)
  end
  
  # short
  def short_uniq
    self.split("").uniq.sort.join("")
  end

  def short_split
    self.split("").uniq.sort.collect { |r| r.to_sym }
  end

  def short(val)
    invert = val.invert
    new = []
    long_split.each do |c| 
      res = invert[c.to_sym]
      if res.nil?
        new.push c
      else
        new.push res.to_s
      end
    end

    new.sort.join("")
  end

  def short_access
    short(AMX_ACCESS_SHORT)
  end
  
  def short_flags
    short(AMX_FLAGS)
  end

  def add(argument)
    (self + argument).short_uniq
  end

  def del(argument)
    (self.short_split - argument.short_split).join("")
  end

  def has?(obj)
    if obj.is_a?(Array)
      return true if obj.size == 0
      return obj.collect { |i| self.include?(i) }.uniq == [true]
    elsif obj.is_a?(String)
      return has?(obj.split(""))
    else
      return include?(obj)
    end
  end

end

