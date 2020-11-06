require 'watir'

browser_preferences = { download: {prompt_for_download: false}, plugins: {always_open_pdf_externally: true}, credentials_enable_service: false, password_manager_enabled: false }
settings = ['disable-session-crashed-bubble', 'enable-dom-distiller', 'incognito', 'disable-infobars', 'disable-gpu', 'no-sandbox', 'disable-default-apps', 'noerrdialogs', 'disable-blink-features=AutomationControlled']
@browser = Watir::Browser.new :chrome, options: { prefs: browser_preferences, options: {'w3c': false, 'useAutomationExtension': false, 'excludeSwitches': ['enable-automation'], 'args': settings }}

#PA_URL = "http://pennsylvaniaobits.tributes.com/search/obituaries/?solr=&first=&last=&city=#{city}&state=PA&search_type=2018"
#MI_URL = "http://michiganobits.tributes.com/search/obituaries?last=&city=#{city}&state=MI&search_type=1&dod="

@base_filename = "dir/where/you/want/the/files"
cities = []
('A'..'Z').each do |alpha|
  @browser.goto("http://michiganobits.tributes.com/browse_obituaries?alpha=#{alpha}&state=MI")
  @browser.ul(id: 'alpha-state-list').wait_until(timeout: 20, &:present?).lis.each do |li|
    cities << li.text
  end
end
cities.each do |city|
  @browser.goto("http://michiganobits.tributes.com/search/obituaries?last=&city=#{city}&state=MI&search_type=1&dod=")
  @browser.select(id: 'select_display_results_count').wait_until(timeout: 20, &:present?).select('50')
  pages = []
  @browser.div(class: 'trib2SearchPagination').wait_until(timeout: 20, &:present?).lis.each{|li| pages << li.text if li.visible? && !li.text.squish.empty? && li.text =~ /\d/}; nil
  people_list = Hash.new
  pages.each do |page|
    @browser.ul(id: 'results-item-list-id').wait_until(timeout: 20, &:present?).lis.each do |li|
      next if li.text.squish.empty?
      details = li.text.split("\n")
      people_list[details.shift] = details
    end; nil
    @browser.li(id: "page_bar_#{page}").links.first.click if page.to_i > 1
    sleep(1)
  end
  file = @base_filename + "#{city}.json"
  File.open(file,"w") do |f|
    f << people_list.as_json
  end
end
