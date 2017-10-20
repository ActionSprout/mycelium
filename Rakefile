require 'json'

desc "Import data in to neo4j from fern postgres"
task :import do
  session = setup_neo4j_session

  puts "Importing organizations"

  batch_import_sql_to_cypher(session, "SELECT id,name,fb_page_id FROM organizations WHERE enabled='t'", <<~CYPHER)
    MERGE (org:Organization { fern_id: row.id }) ON CREATE SET org.name = row.name
    MERGE (page:Page { facebook_page_id: row.fb_page_id })
    MERGE (org)-[:manages]->(page)
  CYPHER

#   puts "Importing posts"
#
#   # TODO: something like find_each?
#   result = import_sql_to_cypher(session, "SELECT facebook_post_id,organization_id FROM posts LIMIT 100", <<~CYPHER)
#     MATCH (org:Organization { fern_id: row.organization_id })-[:manages]->(page:Page)
#     MERGE (post:Post { facebook_post_id: row.facebook_post_id })
#     MERGE (page)-[:shared]->(post)
#     return count(row) as loaded_count
#   CYPHER
#
#   p result

#   result = session.query('match (o:Organization)-[:manages]->(p:Page) return o,p limit 10');
#
#   result.each do |row|
#     p row
#   end
end

def setup_neo4j_session
  require 'neo4j-core'
  require 'neo4j/core/cypher_session/adaptors/http'

  adapter = Neo4j::Core::CypherSession::Adaptors::HTTP.new('http://neo4j:7474')
  Neo4j::Core::CypherSession.new(adapter)
end

# sql MUST expect a trailing AND
# cypher MUST return loaded_count and last_id
def batch_import_sql_to_cypher(session, sql, cypher)
  last_id = 0

  cypher = "#{cypher} RETURN COUNT(row) AS loaded_count, MAX(row.id) AS last_id"
  sql = "#{sql} AND id > ? ORDER BY id ASC LIMIT ?"

  while last_id
    results = import_sql_to_cypher(session, sql, cypher, jdbc_params: [last_id, 1000])

    result = results.first
    loaded_count = result.loaded_count
    last_id = result.last_id

    puts "Loaded #{loaded_count.inspect} organizations ending at #{last_id.inspect}"
  end
end

def import_sql_to_cypher(session, sql, cypher, jdbc_params: [], params: {})
  session.query cypher_for_import(sql, cypher, jdbc_params), params
end

def cypher_for_import(sql, cypher, params = [])
  <<~CYPHER
  WITH "jdbc:postgresql://fern_db/fern_development?user=rails&password=noodlejam" as url
  CALL apoc.load.jdbcParams(url, "#{sql}", #{JSON.dump(params)}) YIELD row

  #{cypher}
  CYPHER
end

