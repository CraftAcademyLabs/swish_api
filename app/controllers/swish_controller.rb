class SwishController < ApplicationController

  def create_payment
    payload = {
      callbackUrl: 'https://dac2474d.ngrok.io/swish/callback',
      payeeAlias: '1231181189',
      amount: 1000,
      currency: 'SEK'
    }
    response = post_request('https://mss.cpc.getswish.net/swish-cpcapi/api/v1/paymentrequests/', payload)
    render json: response.headers
  end

  def callback
    # binding.pry
  end

  private

  def post_request(url, payload = {})
    p12 = OpenSSL::PKCS12.new(File.read("Swish_Merchant_TestCertificate_1231181189.p12"), "swish")
    cert_store = OpenSSL::X509::Store.new
    p12.ca_certs.each do | cert |
      cert_store.add_cert(cert)
    end
    RestClient::Request.execute({
      method: :post,
      url: url,
      payload: payload.to_json,
      ssl_client_cert: p12.certificate,
      ssl_client_key: p12.key,
      ssl_cert_store: cert_store,
      ssl_ca_file: 'Swish_TLS_RootCA.pem',
      headers: { content_type: "application/json" }
      })
  end
end
