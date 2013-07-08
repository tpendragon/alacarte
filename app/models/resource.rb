# == Schema Information
#
# Table name: resources
#
#  id       :integer          not null, primary key
#  mod_id   :integer
#  mod_type :string(255)
#

class Resource < ActiveRecord::Base
  belongs_to :mod, polymorphic: true
  has_and_belongs_to_many :users
  has_many :tab_resources, dependent: :destroy
  has_many :tabs, through: :tab_resources

  has_many :resourceables, dependent: :destroy
  has_many :units, through: :resourceables

  has_many :guides
  has_many :pages

  attr_protected :id

  def self.global_modules(s, rev)
    global_mods = all.collect { |a| a.mod if a.mod and a.mod.global? }.compact
    unless global_mods.empty?
      if s == "label"  || s == "content_type" || s == "created_by"
        global_mods = global_mods.sort! { |a,b| a.send(s).downcase <=> b.send(s).downcase }
      else
        global_mods = global_mods.sort! { |a,b| b.send(s) <=> a.send(s) }
      end
      global_mods = global_mods.reverse if rev == 'true'
      global_mods.uniq
    else
      []
    end
  end

  def copy_mod(name)
    old_mod = mod
    new_mod = old_mod.clone
    case old_mod.class.to_s
    when "DatabaseResource"
      new_mod.database_dods << old_mod.database_dods.collect{|d| d.clone}.flatten
    when "UploaderResource"
      new_mod.uploadables << old_mod.uploadables
    when "RSSResource"
      new_mod.feeds << old_mod.feeds.collect{|f| f.clone}.flatten
    when "VideoResource"
      new_mod.videos << old_mod.videos.collect{|f| f.clone}.flatten
    when "UrlResource"
      new_mod.links << old_mod.links.collect{|f| f.clone}.flatten
    when "BookResource"
      new_mod.books << old_mod.books.collect{|f| f.clone}.flatten
    when "ImageResource"
      new_mod.images << old_mod.images.collect{|f| f.clone}.flatten
    when "QuizResource"
      new_mod.questions << old_mod.copy_questions
    end
    new_mod.label =  old_mod.label+'-'+name
    new_mod.global= false
    new_mod.save
    new_mod
  end

  def create_slug(trunc = 25, truncate_string = "...")
    text = mod.label
    l = trunc - truncate_string.mb_chars.length
    chars = text.mb_chars
    mod.slug = (chars.length > trunc ? chars[0...l] + truncate_string : text).to_s
    mod.save
  end

  def delete_mods
    self.mod.destroy
  end

  def shared?
    users.length > 1
  end
end
