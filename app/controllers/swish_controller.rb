class SwishController < ApplicationController

  def create_payment
    payload = {
      callbackUrl: 'https://7b493249.ngrok.io/swish/callback',
      payeeAlias: '1231181189',
      payerAlias: '46733235555',
      amount: 1000,
      currency: 'SEK'
    }
    response = swish_call(:post, 'https://mss.cpc.getswish.net/swish-cpcapi/api/v1/paymentrequests/', payload)
    body = ping_swish(response.headers[:location])
    render json: body
  end

  def callback
    puts 'PAYMENT SUCCESSFUL'
  end

  private

  def ping_swish(order)
    sleep 4
    response = swish_call(:get, order)
    body = JSON.parse(response.body)
    body['status'] != 'CREATED' ? body : ping_swish(order)
  end

  def swish_call(method, url, payload = {})
    p12 = OpenSSL::PKCS12.new(File.read("Swish_Merchant_TestCertificate_1231181189.p12"), "swish")
    cert_store = OpenSSL::X509::Store.new
    p12.ca_certs.each do | cert |
      cert_store.add_cert(cert)
    end
    RestClient::Request.execute({
      method: method,
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
