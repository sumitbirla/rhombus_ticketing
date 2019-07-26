class Customer < ActiveRecord::Base
  self.table_name = "crm_customers"
  
  belongs_to :pbx_domain
  belongs_to :affiliate
	
	has_many :cases
  has_many :comments, -> { order(created_at: :desc) }, as: :commentable
  has_many :extra_properties, as: :extra_property
  
	accepts_nested_attributes_for :comments, allow_destroy: true, reject_if: proc { |attributes| attributes['content'].blank? }
  accepts_nested_attributes_for :extra_properties, allow_destroy: true
  
  before_validation :normalize_phones
  
  validate :contact_info
	validates_presence_of :affiliate_id, :name
	validates_uniqueness_of :mobile_phone, allow_blank: true, scope: :pbx_domain_id
	validates_uniqueness_of :other_phone, allow_blank: true, scope: :pbx_domain_id
  
  def contact_info
    if mobile_phone.blank? && other_phone.blank? && email.blank?
      errors.add(:base, "Must have at least one phone number or email address.")
    end
  end
  
  def calls(pbx_domain_id)
    list = []
    list << mobile_phone unless mobile_phone.blank?
    list << other_phone unless other_phone.blank?
    
    PbxDbCdr.where(pbx_domain_id: pbx_domain_id)
            .where("sip_from_user IN (?) OR sip_req_user IN (?)", list, list)
            .order(start_time: :desc)
  end
  
  def get_property(name)
    a = extra_properties.find { |x| x.name == name }
    a.nil? ? "" : a.value
  end
  
  def set_property(name, value)
    a = extra_properties.find { |x| x.name == name }
    if [true, false].include? value
      value = (value ? "Yes" : "No")
    end
    
    if a.nil?
      self.extra_properties.build(name: name, value: value) unless value.blank?
    else
      if value.blank?
        a.destroy
      else
        a.update(value: value)
      end
    end
  end
  
  def to_s
    name
  end
        
  
	private
  
		def normalize_phones
			self.mobile_phone.gsub!(/\D/, '') unless mobile_phone.blank?
      self.other_phone.gsub!(/\D/, '') unless other_phone.blank?
		end
    
end
