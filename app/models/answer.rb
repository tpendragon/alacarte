class Answer < ActiveRecord::Base
  belongs_to :question
  acts_as_list :scope => :question

  validates :value, :presence => { :on => :update, :message => "Answer can not be blank", :unless => :skip_it }
  validates :feedback, :presence => { :on => :update, :message => "Feedback can not be blank", :if => :feedback_type }

  def skip_it
    question.q_type.in? %w(TF FW)
  end

  def feedback_type
    question.q_type =='FMC'
  end
end
