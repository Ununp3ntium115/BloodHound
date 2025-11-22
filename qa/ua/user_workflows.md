# User Acceptance Test Workflows

## Workflow 1: Initial Setup

1. Install BloodSniffer
2. Configure `bloodsniffer.toml`
3. Start server
4. Verify health endpoint

**Expected**: Server starts successfully, health check returns OK

## Workflow 2: Data Extraction

1. Provide BloodHound JSON file
2. Call `/api/extract` endpoint
3. Verify Cryptex structure created
4. Check function organization

**Expected**: Data extracted, functions organized in Cryptex

## Workflow 3: Function Translation

1. Use MCP translator
2. Translate Go codebase
3. Verify Cryptex output
4. Review function mapping

**Expected**: Functions translated with anarchist naming

## Workflow 4: Node-RED Integration

1. Configure Node-RED bridge
2. Create data pipeline
3. Send data through pipeline
4. Verify data received

**Expected**: Data flows through Node-RED successfully

## Workflow 5: Fire Marshal Monitoring

1. Start Fire Marshal
2. Create pipeline
3. Monitor pipeline status
4. Check statistics

**Expected**: Monitoring shows active pipelines

