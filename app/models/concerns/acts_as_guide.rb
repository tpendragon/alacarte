module ActsAsGuide
  extend ActiveSupport::Concern

  def self.included base
    base.class_eval do
      after_create :create_home_tab, :create_relateds

      acts_as_taggable
      has_and_belongs_to_many :users
      has_many :tabs, -> { order 'position' }, as: 'tabable', dependent: :destroy
      has_and_belongs_to_many :subjects, -> { order 'subject_code' }
      belongs_to :node

      serialize :relateds

      searchable do
        text :guide_name, :description
      end
    end
  end

  def to_param
    "#{ id }-#{ guide_name.parameterize }"
  end

  def item_name
    guide_name
  end

  def add_contact_node mid
    self.node_id = if mid then mid.to_i else nil end
  end

  def toggle_published
    if self.node || self.published?
      self.toggle!(:published)
      true
    else
      false
    end
  end

  def add_tags tags
    self.tag_list = tags
    self.save
  end

  def create_home_tab
    if tabs.blank?
      add_tab Tab.new(tab_name: _('Start'))
    end
  end

  def add_tab tab
    tabs << tab
  end

  def reached_limit?
    tabs.length > 6
  end

  def nodes
    tabs.flat_map &:nodes
  end

  def recent_nodes
    tabs.flat_map &:recent_nodes
  end

  def shared?
    users.length > 1
  end

  def add_user user
    users << user
  end

  def update_users
    tabs.map(&:nodes).each do |node|
      users.each do |user|
        user.nodes << node unless(user.id == @user || user.nodes.include?(node) == true)
      end
    end
  end

  def share uid, copy
    user = User.find uid
    if copy == '1'
      new_item = replicate user, 'copy'
      new_item.users << user
    else
      users << user
      tabs.flat_map(&:nodes).each { |node| user.nodes << node }
    end
  end

  def copy_nodes uid, tbs
    # Need an id to add tabs
    save
    tabs.destroy_all
    reload
    user = User.find uid
    tbs.each do |tab|
      mod_copies = tab.tab_nodes.flat_map { |r| r.node.copy }
      tab_copy = tab.dup
      if tab_copy.save
        mod_copies.each do |mod|
          mod.update_attribute :created_by, user.name
          user.nodes << mod
          tab_copy.add_node mod
        end
        add_tab tab_copy
      end
    end
  end

  def copy_tabs tbs
    # Need an id to add tabs
    save
    tabs.destroy_all
    reload
    tbs.each do |tab|
      tab_copy = tab.dup
      if tab_copy.save
        tab.tab_nodes.each do |res|
          tab_copy.add_node res
        end
        add_tab tab_copy
      end
    end
  end

  # Defaults related guides on creation.
  def create_relateds
    update_attribute :relateds, get_related_guides
  end

  def delete_relateds id
    relateds.delete id.to_i
    save
  end

  def add_related_guides ids
    ids.each do |id|
      relateds << id.to_i unless relateds.include? id.to_i
    end
  end

  # Return a safe list of related guides.
  def related_guides
    guides = []
    if relateds == nil
      create_relateds
    end
    relateds.each do |id|
      if Guide.exists? id.to_i
        guide = Guide.find id.to_i
        if guide.published?
          guides << guide
        else
          relateds.delete id.to_i
        end
      else
        relateds.delete id.to_i
      end
    end
    guides.sort_by { |x| x.guide_name.downcase }
  end

  # Defines the list of related guides to be those suggested by master subject.
  def suggested_relateds
    add_related_guides get_related_guides
    save
    related_guides
  end
end
