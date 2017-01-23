require 'spec_helper'

RSpec.describe ShortUrlService do
  describe "#shorten" do
    let(:url) { nil }
    let(:shortcode) { nil }
    let(:params) { { url: url, shortcode: shortcode} }
    context "without url" do
      it 'should raise ShortenException::UrlPresenceErrorException with message "url is not present"' do
        expect {
          ShortUrlService.shorten(params)
        }.to raise_error(ShortenException::UrlPresenceErrorException).with_message('url is not present')
      end
    end
    context "giving an empty url" do
      let(:url) { '' }
      it 'should raise ShortenException::UrlPresenceErrorException with message "url is not present"' do
        expect {
          ShortUrlService.shorten(params)
        }.to raise_error(ShortenException::UrlPresenceErrorException).with_message('url is not present')
      end
    end
    context "giving a valid url" do
      let(:url) { 'http://www.google.com' }
      context "with invalid shortcode" do
        context "giving less than 4 chars" do
          let(:shortcode) { 'abc' }
          it 'should raise ShortenException::ShortCodeFormatException with message "The shortcode fails to meet the following regexp: ^[0-9a-zA-Z_]{4,}$."' do
            expect {
              ShortUrlService.shorten(params)
            }.to raise_error(ShortenException::ShortCodeFormatException).with_message('The shortcode fails to meet the following regexp: ^[0-9a-zA-Z_]{4,}$.')
          end
        end
        context "giving more than 4 chars" do
          context "giving not alfanumeric chars" do
            let(:shortcode) { 'abc#' }
            it 'should raise ShortenException::ShortCodeFormatException with message "The shortcode fails to meet the following regexp: ^[0-9a-zA-Z_]{4,}$."' do
              expect {
                ShortUrlService.shorten(params)
              }.to raise_error(ShortenException::ShortCodeFormatException).with_message('The shortcode fails to meet the following regexp: ^[0-9a-zA-Z_]{4,}$.')
            end
          end
        end
      end
      context "with valid shortcode" do
        context "with existent shortcode" do
          let(:shortcode) { 'existent01' }
          before :each do
            ShortUrl.create(url:url, shortcode: shortcode)
          end
          it 'should raise ShortenException::ShortcodeAlreadyInUseException with message "The the desired shortcode is already in use. Shortcodes are case-sensitive."' do
            expect {
              ShortUrlService.shorten(params)
            }.to raise_error(ShortenException::ShortcodeAlreadyInUseException).with_message('The the desired shortcode is already in use. Shortcodes are case-sensitive.')
          end
        end
        context "with inexistent shortcode" do
          let(:shortcode) { 'inexistent02' }
          it 'should create a new ShortUrl' do
            expect {
              ShortUrlService.shorten(params)
            }.to change(ShortUrl,:count).by(1)
          end
        end
      end
      context "without shortcode" do
        it 'should have a call of generate_shortcode! from ShortUrl' do
          new_short_url = ShortUrl.new(params)
          spy(new_short_url)
          allow(ShortUrl).to receive(:new).with(params) { new_short_url }
          expect(new_short_url).to receive(:generate_shortcode!)
          ShortUrlService.shorten(params)
        end
        it 'should create a new ShortUrl' do
          expect {
            ShortUrlService.shorten(params)
          }.to change(ShortUrl,:count).by(1)
        end
      end
    end
  end
end