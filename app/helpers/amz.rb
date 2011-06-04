

Mainboard.helpers do

  def amz_headers header_name
    @amz_headers[header_name.to_s]
  end


  def amz_requested_acl
    amz_headers('x-amz-acl') || 'private'
  end

  def subresource
    res = request.params.keys.first if request.params
    res.to_sym if res.respond_to? :to_sym
  end

  # FIXME
  # quick&dirt, could be much better
  #
  def acl_parse document, object
    doc =  XmlSimple.xml_in(document, 'ForceArray' => false )

    logger.debug "-- permission document --"
    pub = []
    auth = []

    doc['AccessControlList']['Grant'].each do |grant|
      case grant['Grantee']['xsi:type']
      when 'Group'
        if  grant['Grantee']['URI'] &&
          grant['Grantee']['URI'].include?('AuthenticatedUsers')
          if grant['Permission']
            perm = grant['Permission'].downcase.to_sym
            auth << perm if object.class.perms.include? perm
          end
        elsif grant['Grantee']['URI'] &&
          grant['Grantee']['URI'].include?('AllUsers')
          if grant['Permission']
            perm = grant['Permission'].downcase.to_sym
            pub << perm if object.class.perms.include? perm
          end
        end
      when 'CanonicalUser'
        #TODO
      end
    end

    logger.debug pub.pretty_inspect
    logger.debug auth.pretty_inspect

    object.public_access = pub
    object.auth_access = auth
  end


  def acl_document object
    content_type :xml

    builder { |x|
      x.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"
      x.AccessControlPolicy do
        x.Owner {
          x.ID object.owner.key
          x.DisplayName object.owner.identity
        }

        x.AccessControlList do
          x.Grant do
            x.Grantee :'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
                      :'xsi:type' => 'CanonicalUser' do
              x.ID object.owner.key
              x.DisplayName object.owner.identity
            end
            x.Permission 'FULL_CONTROL'
          end
          object.public_access.each do |p|
            x.Grant do
              x.Grantee :'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
                        :'xsi:type' => 'Group' do
              x.URI 'http://acs.amazonaws.com/groups/global/AllUsers'
              end
              x.Permission p.to_s.upcase
            end
          end
          object.auth_access.each do |p|
             x.Grant do
               x.Grantee :'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
                         :'xsi:type' => 'Group' do
                 x.URI 'http://acs.amazonaws.com/groups/global/AuthenticatedUsers'
               end
               x.Permission p.to_s.upcase
             end
           end
          # iterate over other grants
        end

      end
    }
  end
end
