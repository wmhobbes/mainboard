Admin.helpers do

  def allow_attributes(attrs, *filter)
    logger.error filter.pretty_inspect
    attrs.select { |k,v| logger.error k.to_sym.pretty_inspect; filter.include? k.to_sym }
  end

  def only_admin_or_owner_of(target)
   halt 404, "Not Found" unless current_account.administrator? or target.owned_by?(current_account)

  rescue
    halt 404, "Not Found"
  end


end
