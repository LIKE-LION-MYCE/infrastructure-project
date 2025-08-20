#!/bin/bash

# Simple Redis Migration Script: Upstash -> EC2 Redis  
# Uses GET/SET approach to handle version differences

UPSTASH_URL="rediss://default:AXLTAAIjcDFmYjQ1YmU5Nzk5Mjk0MWI0ODUwM2I1OTlhZmI0ZDI4MnAxMA@smooth-gnu-29395.upstash.io:6379"
EC2_REDIS_HOST="43.203.41.54"
EC2_REDIS_PASSWORD="MyceLoadTest2025!"

echo "🚀 Starting simple Redis migration from Upstash to EC2..."

# Clear existing data in EC2 (except our test ad: keys)
echo "🧹 Clearing existing EC2 Redis (keeping ad: keys)..."
redis-cli -h "$EC2_REDIS_HOST" -a "$EC2_REDIS_PASSWORD" --no-auth-warning del testkey 2>/dev/null || true

# Get all keys from Upstash
echo "📋 Getting all keys from Upstash Redis..."
mapfile -t keys < <(redis-cli -u "$UPSTASH_URL" --no-auth-warning keys "*" 2>/dev/null)

if [ ${#keys[@]} -eq 0 ]; then
    echo "❌ No keys found in Upstash Redis"
    exit 1
fi

key_count=${#keys[@]}
echo "📊 Found $key_count keys to migrate"

# Migrate each key with GET/SET, preserving TTL
migrated=0
failed=0
skipped=0

for key in "${keys[@]}"; do
    if [ -n "$key" ]; then
        # Skip if key already exists in EC2 (our existing ad: keys)
        exists=$(redis-cli -h "$EC2_REDIS_HOST" -a "$EC2_REDIS_PASSWORD" --no-auth-warning exists "$key" 2>/dev/null)
        if [ "$exists" -eq 1 ] && [[ "$key" == "ad:"* ]]; then
            echo "⏭️  Skipping existing key: $key"
            ((skipped++))
            continue
        fi
        
        echo "🔄 Migrating: $key"
        
        # Get TTL first (in seconds)
        ttl=$(redis-cli -u "$UPSTASH_URL" --no-auth-warning ttl "$key" 2>/dev/null)
        
        # Get key type 
        key_type=$(redis-cli -u "$UPSTASH_URL" --no-auth-warning type "$key" 2>/dev/null)
        
        case "$key_type" in
            "string")
                # Get string value
                value=$(redis-cli -u "$UPSTASH_URL" --no-auth-warning get "$key" 2>/dev/null)
                if [ -n "$value" ] && [ "$value" != "(nil)" ]; then
                    # Set in EC2
                    set_result=$(redis-cli -h "$EC2_REDIS_HOST" -a "$EC2_REDIS_PASSWORD" --no-auth-warning set "$key" "$value" 2>/dev/null)
                    
                    # Set TTL if exists
                    if [ "$ttl" -gt 0 ]; then
                        redis-cli -h "$EC2_REDIS_HOST" -a "$EC2_REDIS_PASSWORD" --no-auth-warning expire "$key" "$ttl" 2>/dev/null
                        echo "✅ Migrated $key (TTL: ${ttl}s)"
                    else
                        echo "✅ Migrated $key (no expiry)"
                    fi
                    ((migrated++))
                else
                    echo "❌ Failed to get value for key: $key"
                    ((failed++))
                fi
                ;;
            "list")
                # Get all list elements
                list_vals=$(redis-cli -u "$UPSTASH_URL" --no-auth-warning lrange "$key" 0 -1 2>/dev/null)
                if [ -n "$list_vals" ]; then
                    # Delete existing key and recreate
                    redis-cli -h "$EC2_REDIS_HOST" -a "$EC2_REDIS_PASSWORD" --no-auth-warning del "$key" 2>/dev/null
                    
                    # Push all elements 
                    while IFS= read -r item; do
                        if [ -n "$item" ]; then
                            redis-cli -h "$EC2_REDIS_HOST" -a "$EC2_REDIS_PASSWORD" --no-auth-warning rpush "$key" "$item" 2>/dev/null
                        fi
                    done <<< "$list_vals"
                    
                    # Set TTL if exists
                    if [ "$ttl" -gt 0 ]; then
                        redis-cli -h "$EC2_REDIS_HOST" -a "$EC2_REDIS_PASSWORD" --no-auth-warning expire "$key" "$ttl" 2>/dev/null
                        echo "✅ Migrated list $key (TTL: ${ttl}s)"
                    else
                        echo "✅ Migrated list $key (no expiry)"
                    fi
                    ((migrated++))
                else
                    echo "❌ Failed to get list values for key: $key"
                    ((failed++))
                fi
                ;;
            *)
                echo "⚠️  Unsupported key type $key_type for key: $key, skipping"
                ((skipped++))
                ;;
        esac
    fi
done

echo ""
echo "🎉 Migration completed!"
echo "✅ Migrated: $migrated keys"
echo "❌ Failed: $failed keys"  
echo "⏭️  Skipped: $skipped keys"

# Verify migration
echo ""
echo "🔍 Verifying migration..."
ec2_key_count=$(redis-cli -h "$EC2_REDIS_HOST" -a "$EC2_REDIS_PASSWORD" --no-auth-warning dbsize 2>/dev/null)
echo "📊 EC2 Redis now contains: $ec2_key_count keys"

echo ""
echo "🏁 Migration finished!"