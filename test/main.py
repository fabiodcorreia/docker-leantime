import sys
import os
import mechanize

APP_TEST_PORT = "80"

assert len(sys.argv) > 1, "no arguments"

APP_TEST_URL = sys.argv[1]

print "TEST_ULR=" + APP_TEST_URL

def setFormInput(form, input, val):
  form.find_control(input).value = val

def tryFollowLink(link):
  try:
    response = br.follow_link(link)
    assert response.code == 200, "response for " + link.url + " was " + response.code
    return response
  except:
    assert False, "Fail to follow link to : " + link.url

br = mechanize.Browser()
br.set_handle_robots(False)

response = br.open(APP_TEST_URL)
assert response.code == 200, "response code is not 200"
assert response.geturl() == APP_TEST_URL+"/install", "initial page is not /install: " + response.read()

forms = list(br.forms())
assert len(forms) == 1, "registration form not found"
br.form = forms[0]

setFormInput(br.form, "email", "some")
setFormInput(br.form, "password", "some")
setFormInput(br.form, "firstname", "some")
setFormInput(br.form, "lastname", "some")
setFormInput(br.form, "company", "some")

response = br.submit()
assert response.code == 200, "response code is not 200"

response = tryFollowLink(br.find_link(text=APP_TEST_URL))

forms = list(br.forms())

assert len(forms) == 1, "login form not found"

br.form = forms[0]

setFormInput(br.form, "username", "some")
setFormInput(br.form, "password", "some")
response = br.submit()

assert response.code == 200, "response code is not 200"

response = tryFollowLink(br.find_link(text="My Profile"))

response = tryFollowLink(br.find_link(text="Manage two-factor authentication"))

forms = list(br.forms())
assert len(forms) == 2, "2FA form not found"
br.form = forms[1]
br.form.find_control("twoFACode")



