#!/bin/bash
# Test script for Droq Math Executor Node API
# Tests all endpoints and verifies functionality

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
EXECUTOR_URL="${EXECUTOR_URL:-http://localhost:8003}"
STREAM_SERVICE_URL="${STREAM_SERVICE_URL:-http://localhost:8001}"
NATS_URL="${NATS_URL:-nats://localhost:4222}"

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0

# Helper functions
print_header() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_test() {
    echo ""
    echo -e "${YELLOW}$1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
    ((TESTS_PASSED++))
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
    ((TESTS_FAILED++))
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Check if service is running
check_service() {
    local url=$1
    local service_name=$2
    
    if curl -s -f "$url/health" > /dev/null 2>&1; then
        print_success "$service_name is running"
        return 0
    else
        print_error "$service_name is not running at $url"
        return 1
    fi
}

# Test 1: Health Check
test_health_check() {
    print_header "1️⃣  Health Check"
    
    print_test "Testing GET $EXECUTOR_URL/health"
    
    response=$(curl -s "$EXECUTOR_URL/health" 2>&1)
    status_code=$(curl -s -o /dev/null -w "%{http_code}" "$EXECUTOR_URL/health")
    
    if [ "$status_code" = "200" ]; then
        echo "   Response: $response"
        if echo "$response" | grep -q "healthy"; then
            print_success "Health check passed"
            return 0
        else
            print_error "Health check response doesn't contain 'healthy'"
            return 1
        fi
    else
        print_error "Health check failed with status code: $status_code"
        return 1
    fi
}

# Test 2: Service Info
test_service_info() {
    print_header "2️⃣  Service Info"
    
    print_test "Testing GET $EXECUTOR_URL/"
    
    response=$(curl -s "$EXECUTOR_URL/" 2>&1)
    status_code=$(curl -s -o /dev/null -w "%{http_code}" "$EXECUTOR_URL/")
    
    if [ "$status_code" = "200" ]; then
        echo "   Response:"
        echo "$response" | python3 -m json.tool 2>/dev/null || echo "$response"
        print_success "Service info retrieved"
        return 0
    else
        print_error "Service info failed with status code: $status_code"
        return 1
    fi
}

# Test 3: Initialize Stream Topics
test_initialize_topics() {
    print_header "3️⃣  Initialize Stream Topics"
    
    print_test "Testing POST $STREAM_SERVICE_URL/api/v1/topics/initialize"
    
    # Check if stream service is running
    if ! check_service "$STREAM_SERVICE_URL" "Stream Service"; then
        print_error "Stream service not available, skipping topic initialization"
        print_info "Start stream service: cd ../droq-stream-service && uv run droq-stream-service"
        return 1
    fi
    
    init_payload='{
      "user_id": "testuser",
      "flow_id": "testworkflow",
      "component_ids": ["test-dfx-multiply-1"]
    }'
    
    response=$(curl -s -X POST "$STREAM_SERVICE_URL/api/v1/topics/initialize" \
      -H "Content-Type: application/json" \
      -d "$init_payload" 2>&1)
    
    status_code=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$STREAM_SERVICE_URL/api/v1/topics/initialize" \
      -H "Content-Type: application/json" \
      -d "$init_payload")
    
    if [ "$status_code" = "200" ]; then
        echo "   Response:"
        echo "$response" | python3 -m json.tool 2>/dev/null || echo "$response"
        
        success=$(echo "$response" | python3 -c "import sys, json; d=json.load(sys.stdin); print(d.get('success', False))" 2>/dev/null || echo "false")
        topics_count=$(echo "$response" | python3 -c "import sys, json; d=json.load(sys.stdin); print(d.get('topics_initialized', 0))" 2>/dev/null || echo "0")
        
        if [ "$success" = "True" ] && [ "$topics_count" -gt 0 ]; then
            print_success "Topics initialized successfully ($topics_count topic(s))"
            return 0
        else
            print_error "Topic initialization failed or no topics initialized"
            return 1
        fi
    else
        print_error "Topic initialization failed with status code: $status_code"
        return 1
    fi
}

# Test 4: Execute DFXMultiplyComponent
test_execute_component() {
    print_header "4️⃣  Execute DFXMultiplyComponent"
    
    print_test "Testing POST $EXECUTOR_URL/api/v1/execute"
    print_info "Component: DFXMultiplyComponent"
    print_info "Module: dfx.math.component.multiply"
    print_info "Parameters: number1=5.0, number2=3.0"
    print_info "Expected result: 15.0"
    
    payload='{
      "component_state": {
        "component_class": "DFXMultiplyComponent",
        "component_module": "dfx.math.component.multiply",
        "component_code": null,
        "parameters": {
          "number1": 5.0,
          "number2": 3.0
        },
        "input_values": null,
        "config": null,
        "display_name": "DFX Multiply",
        "component_id": "test-dfx-multiply-1",
        "stream_topic": "droq.local.public.testuser.testworkflow.test-dfx-multiply-1.out"
      },
      "method_name": "multiply",
      "is_async": false,
      "timeout": 30,
      "message_id": "test-msg-123"
    }'
    
    response=$(curl -s -X POST "$EXECUTOR_URL/api/v1/execute" \
      -H "Content-Type: application/json" \
      -d "$payload" 2>&1)
    
    status_code=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$EXECUTOR_URL/api/v1/execute" \
      -H "Content-Type: application/json" \
      -d "$payload")
    
    if [ "$status_code" = "200" ]; then
        echo ""
        echo "   Response:"
        echo "$response" | python3 -m json.tool 2>/dev/null || echo "$response"
        echo ""
        
        # Extract and verify result
        success=$(echo "$response" | python3 -c "import sys, json; d=json.load(sys.stdin); print(d.get('success', False))" 2>/dev/null || echo "false")
        result=$(echo "$response" | python3 -c "import sys, json; d=json.load(sys.stdin); r=d.get('result',{}); print(r.get('data',{}).get('result') if isinstance(r,dict) and 'data' in r else 'N/A')" 2>/dev/null || echo "N/A")
        exec_time=$(echo "$response" | python3 -c "import sys, json; d=json.load(sys.stdin); print(f\"{d.get('execution_time',0):.3f}s\")" 2>/dev/null || echo "N/A")
        message_id=$(echo "$response" | python3 -c "import sys, json; d=json.load(sys.stdin); print(d.get('message_id', 'N/A'))" 2>/dev/null || echo "N/A")
        
        echo "   Success: $success"
        echo "   Result: $result"
        echo "   Execution Time: $exec_time"
        echo "   Message ID: $message_id"
        echo ""
        
        if [ "$success" = "True" ] && [ "$result" = "15.0" ]; then
            print_success "Component execution passed - Result is correct!"
            return 0
        else
            print_error "Component execution failed - Result mismatch or execution failed"
            return 1
        fi
    else
        print_error "Component execution failed with status code: $status_code"
        echo "   Response: $response"
        return 1
    fi
}

# Test 5: Execute with different numbers
test_execute_different_numbers() {
    print_header "5️⃣  Execute DFXMultiplyComponent (Different Numbers)"
    
    print_test "Testing POST $EXECUTOR_URL/api/v1/execute with number1=7.5, number2=2.0"
    print_info "Expected result: 15.0 (7.5 × 2.0)"
    
    payload='{
      "component_state": {
        "component_class": "DFXMultiplyComponent",
        "component_module": "dfx.math.component.multiply",
        "component_code": null,
        "parameters": {
          "number1": 7.5,
          "number2": 2.0
        },
        "input_values": null,
        "config": null,
        "display_name": "DFX Multiply",
        "component_id": "test-dfx-multiply-2",
        "stream_topic": "droq.local.public.testuser.testworkflow.test-dfx-multiply-2.out"
      },
      "method_name": "multiply",
      "is_async": false,
      "timeout": 30,
      "message_id": "test-msg-456"
    }'
    
    response=$(curl -s -X POST "$EXECUTOR_URL/api/v1/execute" \
      -H "Content-Type: application/json" \
      -d "$payload" 2>&1)
    
    result=$(echo "$response" | python3 -c "import sys, json; d=json.load(sys.stdin); r=d.get('result',{}); print(r.get('data',{}).get('result') if isinstance(r,dict) and 'data' in r else 'N/A')" 2>/dev/null || echo "N/A")
    success=$(echo "$response" | python3 -c "import sys, json; d=json.load(sys.stdin); print(d.get('success', False))" 2>/dev/null || echo "false")
    
    if [ "$success" = "True" ] && [ "$result" = "15.0" ]; then
        print_success "Different numbers test passed - Result: $result"
        return 0
    else
        print_error "Different numbers test failed - Result: $result (expected: 15.0)"
        return 1
    fi
}

# Test 6: Error handling (invalid component)
test_error_handling() {
    print_header "6️⃣  Error Handling Test"
    
    print_test "Testing POST $EXECUTOR_URL/api/v1/execute with invalid component"
    
    payload='{
      "component_state": {
        "component_class": "InvalidComponent",
        "component_module": "invalid.module",
        "component_code": null,
        "parameters": {},
        "input_values": null,
        "config": null,
        "display_name": "Invalid",
        "component_id": "test-invalid",
        "stream_topic": null
      },
      "method_name": "execute",
      "is_async": false,
      "timeout": 30,
      "message_id": "test-msg-error"
    }'
    
    response=$(curl -s -X POST "$EXECUTOR_URL/api/v1/execute" \
      -H "Content-Type: application/json" \
      -d "$payload" 2>&1)
    
    status_code=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$EXECUTOR_URL/api/v1/execute" \
      -H "Content-Type: application/json" \
      -d "$payload")
    
    if [ "$status_code" = "200" ]; then
        # Check if response has success=false and error field
        success=$(echo "$response" | python3 -c "import sys, json; d=json.load(sys.stdin); print(d.get('success', True))" 2>/dev/null || echo "true")
        error=$(echo "$response" | python3 -c "import sys, json; d=json.load(sys.stdin); print(d.get('error', 'N/A'))" 2>/dev/null || echo "N/A")
        
        if [ "$success" = "False" ] && [ "$error" != "N/A" ]; then
            print_success "Error handling works correctly - Error: $error"
            return 0
        else
            print_error "Error handling test failed - Expected success=false with error field"
            echo "   Response: $response"
            return 1
        fi
    else
        # HTTP error (400, 500, etc.) - also acceptable for error handling
        print_success "Error handling works correctly - HTTP $status_code"
        return 0
    fi
}

# Main test execution
main() {
    echo ""
    echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                    Droq Math Executor Node API Tests                          ║${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BLUE}Configuration:${NC}"
    echo "   Executor URL: $EXECUTOR_URL"
    echo "   Stream Service URL: $STREAM_SERVICE_URL"
    echo "   NATS URL: $NATS_URL"
    echo ""
    
    # Check if executor node is running
    if ! check_service "$EXECUTOR_URL" "Math Executor Node"; then
        print_error "Math Executor Node is not running!"
        print_info "Start it with: uv run droq-math-executor-node 8003"
        exit 1
    fi
    
    # Run tests
    test_health_check
    test_service_info
    test_initialize_topics
    test_execute_component
    test_execute_different_numbers
    test_error_handling
    
    # Summary
    print_header "📊 Test Summary"
    echo ""
    echo -e "${GREEN}✅ Tests Passed: $TESTS_PASSED${NC}"
    echo -e "${RED}❌ Tests Failed: $TESTS_FAILED${NC}"
    echo ""
    
    total_tests=$((TESTS_PASSED + TESTS_FAILED))
    if [ $total_tests -gt 0 ]; then
        success_rate=$(echo "scale=1; $TESTS_PASSED * 100 / $total_tests" | bc)
        echo -e "${BLUE}Success Rate: ${success_rate}%${NC}"
    fi
    echo ""
    
    if [ $TESTS_FAILED -eq 0 ]; then
        echo -e "${GREEN}🎉 All tests passed!${NC}"
        echo ""
        print_info "Check executor node logs for NATS publishing:"
        print_info "   Look for: [NATS] ✅ Published result to ..."
        exit 0
    else
        echo -e "${RED}⚠️  Some tests failed${NC}"
        exit 1
    fi
}

# Run main function
main

