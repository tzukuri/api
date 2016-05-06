if Rails.env.production?
    Stripe.api_key = "sk_live_XBM5zi8XpCF1CtHFJUEsEPwa"
else
    Stripe.api_key = "sk_test_J4tHueX5I07WxHRpgUFKehuw"
end
