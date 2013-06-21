class Guide < ActiveRecord::Base
  acts_as_taggable
  has_and_belongs_to_many :users
  has_many :tabs, :as => 'tabable', :order => 'position', :dependent => :destroy
  has_and_belongs_to_many :masters
  has_and_belongs_to_many :subjects, :order => 'subject_name'
  belongs_to :resource

  validates :guide_name, :presence => true, :uniqueness => true

  serialize :relateds
  after_create :create_relateds

  def to_param
    "#{id}-#{guide_name.gsub(/[^a-z0-9]+/i, '-')}"
  end

  def create_relateds
    update_attribute(:relateds, get_related_guides)
  end

  def delete_relateds(id)
    relateds.delete(id.to_i)
    self.save
  end

  def add_related_guides(ids)
    ids.each do |id|
      relateds << id.to_i unless relateds.include?(id.to_i)
    end
  end

  def related_guides
    guides=[]
    if relateds == nil
      create_relateds
    end
    relateds.each do |id|
      if Guide.exists?(id.to_i)
        guide = Guide.find(id.to_i)
        if guide.published?
          guides << guide
        else
          relateds.delete(id.to_i)
        end
      else
        relateds.delete(id.to_i)
      end
    end
    guides.sort { |x,y| x.guide_name.downcase <=> y.guide_name.downcase }
  end

  def suggested_relateds
    ids = get_related_guides
    add_related_guides(ids)
    self.save
    related_guides
  end

  def get_related_guides
    gds = masters.collect{|m| m.pub_guides(id)}.flatten.uniq
    gds = gds.collect{|a| a.id}.compact if gds
    (gds.blank? ? [] : gds)
  end

  def add_master_type(master_types)
    masters.clear
    if master_types
      master_types.each do |id|
        master = Master.find(id)
        masters << master
      end
    end
  end

  def add_related_subjects(subjs)
    subjects.clear
    if subjs
      subjs.each do |id|
        subject = Subject.find(id)
        subjects << subject
      end
    end
  end

  def add_tags(tags)
    self.tag_list = tags
    self.save
  end

  def add_tab(tab)
    tabs << tab
  end

  def create_home_tab
    tab = Tab.new(:tab_name => 'Quick Links')
    self.tabs << tab
  end

  def reached_limit?
    tabs.length > 6 ? true : false
  end

  def modules
    tbs = []
    tbs << tabs.collect{|t| t.modules}
    tbs.flatten
  end

  def recent_modules
    tabs.collect{|t| t.recent_modules}.flatten
  end

  def related_pages
    subjects.collect{|s| s.get_pages}.flatten.uniq
  end

  def self.published_guides
    self.where(:published => true).order("guide_name").select("id, guide_name, description")
  end

  def shared?
    users.length > 1
  end

  def share(uid, copy)
    user = User.find(uid)
    if copy  == "1"
      share_copy(user)
    else
      users << user
      resources =  tabs.collect{|t| t.resources}.compact
      resources.each do |resource|
        user.add_resource(resource)
      end
    end
  end

  def share_copy(user)
    guide_copy = clone
    guide_copy.guide_name = guide_name + '-copy'
    subjects.each do |subject|
      guide_copy.subjects << subject
    end
    masters.each do |master|
      guide_copy.masters << master
    end
    guide_copy.created_by = user.id
    guide_copy.published = false
    guide_copy.save

    guide_copy.users << user

    tabs.each do |tab|
      mod_copies = tab.tab_resources.collect{|r| r.resource.copy_mod(guide_name)}.flatten
      tab_copy = tab.clone
      if tab_copy.save
        mod_copies.each do |mod|
          resource = Resource.create(:mod => mod)
          user.add_resource(resource)
          tab_copy.add_resource(resource)
        end
        guide_copy.add_tab(tab_copy)
      end
    end
  end

  def copy_resources(uid, tbs)
    user = User.find(uid)
    tbs.each do |tab|
      mod_copies = tab.tab_resources.collect{|r| r.resource.copy_mod(tab.guide.guide_name)}.flatten
      tab_copy = tab.clone
      if tab_copy.save
        mod_copies.each do |mod|
          mod.update_attribute(:created_by, user.name)
          resource = Resource.create(:mod => mod)
          user.add_resource(resource)
          tab_copy.add_resource(resource)
        end
        add_tab(tab_copy)
      end
    end
  end

  def copy_tabs(tbs)
    tbs.each do |tab|
      tab_copy = tab.clone
      if tab_copy.save
        tab.tab_resources.each do |res|
          tab_copy.add_resource(res.resource)
        end
        add_tab(tab_copy)
      end
    end
  end

  def update_users
    resources =  tabs.collect{|t| t.resources}.compact
    resources.each do |resource|
      users.collect{|user| user.add_resource(resource) unless(user.id == @user || user.resources.include?(resource) == true)}
    end
  end

  def toggle_published
    if self.resource || self.published?
      self.toggle!(:published)
      return true
    else
      return false
    end
  end

  def index_masters
    masters.map{|master| master.value}.join(", ")
  end

  def index_subjects_name
    subjects.map{|subject| subject.subject_name}.join(", ")
  end

  def index_subjects_code
    subjects.map{|subject| subject.subject_code}.join(", ")
  end

  def index_tab_name
    tabs.map{|tab| tab.tab_name}.join(", ")
  end
end
