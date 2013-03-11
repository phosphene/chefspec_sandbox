module UtilLib

  def get_remote_db_backup (config)
    bucket = get_storage_bucket config
    bucket.files.all(:prefix => "#{config['client']}/").last
  end


  def get_storage_bucket(config)

    storage = Fog::Storage.new(
                               :provider => 'AWS',
                               :aws_access_key_id => config['aws_access_key_id'],
                               :aws_secret_access_key => config['aws_secret_access_key']
                               )
    storage.directories.get('color-db-backup')
  end



end
