module ApplicationHelper
  def itunes_namespace
    {
      'xmlns:itunes' => 'http://www.itunes.com/dtds/podcast-1.0.dtd',
      'version' => '2.0'
    }
  end
end
