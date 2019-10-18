#%%
import tfx
import ml_metadata
from ml_metadata import metadata_store
from ml_metadata.proto import metadata_store_pb2

#%%
connection_config = metadata_store_pb2.ConnectionConfig()
connection_config.mysql.host = '35.192.177.172'
connection_config.mysql.port = ''

#%%
