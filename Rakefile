require 'json'
require 'logger'

desc "Import data in to neo4j from fern postgres"
task :import do
  session = setup_neo4j_session

  import_organizations session
  import_posts session
  import_people session
  import_engagement session, 'likes'
  import_engagement session, 'comments'
end

def setup_neo4j_session
  require 'neo4j-core'
  require 'neo4j/core/cypher_session/adaptors/http'

  adapter = Neo4j::Core::CypherSession::Adaptors::HTTP.new('http://neo4j:7474')
  Neo4j::Core::CypherSession.new(adapter)
end

def import_organizations(session)
  batch_import_sql_to_cypher(session, "organizations", "Organization", "SELECT id,name,fb_page_id FROM organizations t WHERE enabled='t' AND", <<~CYPHER)
    MERGE (org:Organization { fern_id: row.id }) ON CREATE SET org.name = row.name
    MERGE (page:Page { facebook_page_id: row.fb_page_id })
    MERGE (org)-[:manages]->(page)
  CYPHER
end

def import_posts(session)
  batch_import_sql_to_cypher(session, "posts", "Post", "SELECT id,facebook_post_id,organization_id FROM posts t WHERE", <<~CYPHER)
    MATCH (org:Organization { fern_id: row.organization_id })-[:manages]->(page:Page)
    MERGE (post:Post { facebook_post_id: row.facebook_post_id })
      ON CREATE SET post.fern_id = row.id
      ON MATCH SET post.fern_id = row.id
    MERGE (page)-[:shared]->(post)
  CYPHER
end

def import_people(session)
  batch_import_sql_to_cypher(session, "people", "Person", "SELECT id,third_party_id,name,email,facebook_user_id FROM people t WHERE", <<~CYPHER)
    MERGE (person:Person { fern_id: row.id })
      ON CREATE SET person.name = row.name,
        person.facebook_user_id = row.facebook_user_id,
        person.third_party_id = row.third_party_id,
        person.email = row.email
  CYPHER
end

def import_engagement(session, engagement)
  selects = %w[
    t.id
    t.facebook_post_id
    t.created_at
    a.person_id
  ].join(',')

  batch_import_sql_to_cypher(session, engagement, nil, "SELECT #{selects} FROM #{engagement} t INNER JOIN affiliations a ON a.id = t.affiliation_id WHERE", <<~CYPHER)
    MATCH (person:Person { fern_id: row.person_id })
    MATCH (post:Post { facebook_post_id: row.facebook_post_id })
    MERGE (person)-[e:#{engagement}]->(post)
      ON CREATE SET e.created_at = row.created_at
  CYPHER
end

# sql MUST begin a WHERE clause and call the main table: `t`
# cypher MUST expect a trailing RETURN
def batch_import_sql_to_cypher(session, table_name, node_name, sql, cypher)

  if node_name
    last_imported_result = session.query("MATCH (n:#{node_name}) RETURN max(n.fern_id) AS id")
    last_id = last_imported_result.first.id || 0
  else
    last_id = 0
  end

  log "Importing #{table_name} starting with id=#{last_id}"

  cypher = "#{cypher} RETURN COUNT(row) AS loaded_count, MAX(row.id) AS last_id"
  sql = "#{sql} t.id > ? ORDER BY t.id ASC LIMIT ?"

  while last_id
    results = import_sql_to_cypher(session, sql, cypher, jdbc_params: [last_id, 1000])

    result = results.first
    loaded_count = result.loaded_count
    log "Loaded #{loaded_count.inspect} #{table_name} ending at #{last_id.inspect}"

    last_id = result.last_id
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

def log(message)
  $logger ||= Logger.new(STDOUT)
  $logger.debug message
end
