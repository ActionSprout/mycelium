
desc "Import data in to neo4j from fern postgres"
task :import do
  session = setup_neo4j_session

  import_sql_to_cypher(session, "SELECT id,name,fb_page_id FROM organizations WHERE enabled='t' limit 1000", <<~CYPHER)
    MERGE (org:Organization { fern_id: row.id }) ON CREATE SET org.name = row.name
    MERGE (page:Page { facebook_page_id: row.fb_page_id })
    MERGE (org)-[:manages]->(page)
  CYPHER

  # TODO: something like find_each?
  import_sql_to_cypher(session, "SELECT facebook_post_id,organization_id FROM posts LIMIT 100", <<~CYPHER)
    MATCH (org:Organization { fern_id: row.organization_id })-[:manages]->(page:Page)
    MERGE (post:Post { facebook_post_id: row.facebook_post_id })
    MERGE (page)-[:shared]->(post)
  CYPHER

  result = session.query('match (o:Organization)-[:manages]->(p:Page) return o,p limit 10');

  result.each do |row|
    p row
  end
end

def setup_neo4j_session
  require 'socket'
  require 'neo4j-core'
  require 'neo4j/core/cypher_session/adaptors/bolt'

  adapter = Neo4j::Core::CypherSession::Adaptors::Bolt.new('bolt://neo4j:7687')
  Neo4j::Core::CypherSession.new(adapter)
end

def import_sql_to_cypher(session, sql, cypher, params = {})
  session.query cypher_for_import(sql, cypher), params
end

def cypher_for_import(sql, cypher)
  <<~CYPHER
  WITH "jdbc:postgresql://fern_db/fern_development?user=rails&password=noodlejam" as url
  CALL apoc.load.jdbc(url, "#{sql}") YIELD row

  #{cypher}
  CYPHER
end

