require 'tilt/erubis'

module FakeMindBodyApi

  MbBooking = Struct.new(:class_id, :client_id)
  MbUser = Struct.new(:id, :email, :credits, :name, :shoe_size, :birthdate)

  class Application < Sinatra::Base
    set :raise_errors, true
    set :show_exceptions, false

    set :users, []
    set :bookings, []
    set :packages, {}

    def self.find_or_create(id)
      inject_user(id: id)
    end

    def self.find_user(id)
      users.detect do |user|
        user.id == id
      end
    end

    def self.inject_user(id:, name: nil, email: nil, shoe_size: nil,
                         birthdate: nil, credits: 0)
      user = find_user(id)
      if user.nil?
        user = MbUser.new(id, email, credits, name, shoe_size, birthdate)
        settings.users << user
      end
      user.email = email if email.present?
      user.credits = credits if email.present?
      user
    end

    def self.bookings_for_user(user_id)
      bookings.select do |booking|
        booking.client_id == user_id
      end
    end

    def self.register_package(package)
      settings.packages[package.id.to_s] = package
    end

    def self.find_package(id)
      settings.packages[id]
    end

    get "/:service.asmx" do
      service = params.fetch("service")
      if params.has_key?("WSDL")
        render_wsdl(service)
      else
        raise 'unhandled get'
      end
    end

    post "/:service.asmx" do
      action = request.env['HTTP_SOAPACTION'].gsub('"', '').gsub('http://clients.mindbodyonline.com/api/0_5/', '')
      content_type 'text/xml'
      self.send(action.snakecase)
    end

    private

    def render_wsdl(service)
      content_type 'application/wsdl+xml'
      path = Pathname.new("./spec/support/mindbody/#{service.snakecase}.wsdl")
      if path.exist?
        File.read(path)
      else
        raise "no wsdl"
      end
    end

    def get_clients
      File.read("./spec/support/mindbody/get_user.xml")
    end

    def get_staff
      File.read("./spec/support/mindbody/get_staff.xml")
    end

    def get_services
      File.read("./spec/support/mindbody/get_services.xml")
    end

    def get_classes
      File.read("./spec/support/mindbody/get_classes.xml")
    end

    ClientInClassResponse = Struct.new(:id, :action)
    def add_clients_to_classes
      doc = xml_body
      client_ids = doc.xpath("//tns:ClientIDs/tns:string").map(&:text)
      class_id = doc.xpath("//tns:ClassIDs/tns:int").map(&:text).first.to_i

      client_ids.each do |client_id|
        settings.bookings << MbBooking.new(class_id, client_id)
        self.class.find_user(client_id).credits -= 1
      end

      @clients = client_ids.map do |id|
        ClientInClassResponse.new(id, "Added")
      end

      erb :add_clients_to_classes
    end

    def remove_clients_from_classes
      doc = xml_body
      client_id = doc.xpath("//tns:ClientIDs/tns:string").map(&:text).first
      class_id = doc.xpath("//tns:ClassIDs/tns:int").map(&:text).first.to_i

      settings.bookings.delete_if do |booking|
        to_delete = booking.class_id == class_id && booking.client_id == client_id
        if to_delete
          self.class.find_user(client_id).credits += 1
        end
        to_delete
      end

      erb :remove_clients_from_classes
    end

    def get_client_schedule
      doc = xml_body
      client_id = doc.xpath("//tns:ClientID").first.text

      @bookings = self.class.bookings_for_user(client_id)
      erb :get_client_schedule
    end

    def get_client_services
      doc = xml_body
      client_id = doc.xpath("//tns:ClientID").text

      header = <<-HEADER
        <?xml version="1.0" encoding="utf-8"?>
        <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
          <soap:Body>
            <GetClientServicesResponse xmlns="http://clients.mindbodyonline.com/api/0_5">
              <GetClientServicesResult>
                <Status>Success</Status>
                <ErrorCode>200</ErrorCode>
                <XMLDetail>Full</XMLDetail>
                <ResultCount>2</ResultCount>
                <CurrentPageIndex>0</CurrentPageIndex>
                <TotalPageCount>1</TotalPageCount>
                <ClientServices>
      HEADER

      user = self.class.find_or_create(client_id)
      body = user.credits.times.map do
        <<-BODY
                  <ClientService>
                    <Current>true</Current>
                    <Count>1</Count>
                    <Remaining>1</Remaining>
                    <ID>687</ID>
                    <Name>Introductory Offer</Name>
                    <PaymentDate>2016-02-22T00:00:00</PaymentDate>
                    <ActiveDate>2016-02-22T00:00:00</ActiveDate>
                    <ExpirationDate>2017-02-22T00:00:00</ExpirationDate>
                    <Program>
                      <ID>22</ID>
                      <Name>Classes</Name>
                      <ScheduleType>DropIn</ScheduleType>
                      <CancelOffset xsi:nil="true"/>
                    </Program>
                  </ClientService>
        BODY
      end

      footer = <<-FOOTER
                </ClientServices>
              </GetClientServicesResult>
            </GetClientServicesResponse>
          </soap:Body>
        </soap:Envelope>
      FOOTER
      header + body.join + footer
    end


    def checkout_shopping_cart
      # <tns:ClientID>589ff99b-adfa-4c57-8ed1-5fce6408a2b4</tns:ClientID>
      # <tns:CartItems>
      #   <tns:CartItem>
      #     <tns:Quantity>1</tns:Quantity>
      #     <tns:Item xsi:type="tns:Service">
      #       <tns:ID>10101</tns:ID>
      #     </tns:Item>
      #   </tns:CartItem>
      # </tns:CartItems>
      # <tns:Payments>
      #   <tns:PaymentInfo xsi:type="tns:CompInfo">
      #     <tns:Amount>28.0</tns:Amount>
      #   </tns:PaymentInfo>
      # </tns:Payments>
      doc = xml_body
      client_id = doc.xpath("//tns:ClientID").text
      package_id = doc.xpath("//tns:CartItem/tns:Item/tns:ID").first.text

      package = self.class.find_package(package_id)
      user = self.class.find_or_create(client_id)
      user.credits += package.count

      erb :checkout_shopping_cart
    end

    def xml_body
      Nokogiri::XML(request.body.read)
    end

    def add_or_update_clients
      # <tns:Client>
      #   <tns:ID>f30e753c-895a-4372-a1b1-112c33c9f409</tns:ID>
      #   <tns:Email>ben+3@unspace.ca</tns:Email>
      #   <tns:BirthDate>1999-09-09</tns:BirthDate>
      #   <tns:FirstName>Ben3</tns:FirstName>
      #   <tns:MiddleName xsi:nil="true"/>
      #   <tns:LastName>moss3</tns:LastName>
      #   <tns:State>ON</tns:State>
      #   <tns:Country>CA</tns:Country>
      #   <tns:CustomClientFields>
      #     <tns:CustomClientField>
      #       <tns:ID>1</tns:ID>
      #       <tns:Value>10.5</tns:Value>
      #     </tns:CustomClientField>
      #   </tns:CustomClientFields>
      # </tns:Client>

      doc = xml_body
      action = doc.xpath("//tns:UpdateAction").text

      case action
      when 'AddNew'
        add_client(doc)
      when 'Fail'
        update_client(doc)
      else
        raise "Unexpected UpdateAction: #{action}"
      end
    end

    def add_client(doc)
      @id = doc.xpath("//tns:ID").text
      @email = doc.xpath("//tns:Email").text
      birthdate = doc.xpath("//tns:BirthDate").text
      @birthdate = "#{birthdate}T00:00:00"
      @first_name = doc.xpath("//tns:FirstName").text
      @middle_name = doc.xpath("//tns:MiddleName").text
      @last_name = doc.xpath("//tns:LastName").text
      @state = doc.xpath("//tns:State").text
      @country = doc.xpath("//tns:Country").text

      erb :add_client
    end

    def update_client(doc)
      @id = doc.xpath("//tns:ID").first.text

      user = self.class.find_or_create(@id)

      @email = doc.xpath("//tns:Email").text
      birthdate = doc.xpath("//tns:BirthDate").text
      @birthdate = "#{birthdate}T00:00:00"
      @first_name = doc.xpath("//tns:FirstName").text
      @middle_name = doc.xpath("//tns:MiddleName").text
      @last_name = doc.xpath("//tns:LastName").text
      @shoe_size = doc.xpath("//tns:CustomClientFields/tns:CustomClientField/tns:Value").text

      user.name = [@first_name, @middle_name, @last_name].reject(&:blank?).join(' ')
      user.email = @email
      user.shoe_size = @shoe_size
      user.birthdate = @birthdate

      erb :update_client
    end

  end
end
