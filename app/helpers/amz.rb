
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
          # iterate over other grants
        end

      end
    }
  end
end
