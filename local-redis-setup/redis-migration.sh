#!/bin/bash

# Redis Migration Script: Upstash -> EC2 Redis
# Preserves TTL values for all keys

UPSTASH_URL="rediss://default:AXLTAAIjcDFmYjQ1YmU5Nzk5Mjk0MWI0ODUwM2I1OTlhZmI0ZDI4MnAxMA@smooth-gnu-29395.upstash.io:6379"
EC2_REDIS_HOST="43.203.41.54"
EC2_REDIS_PASSWORD="MyceLoadTest2025!"

echo "🚀 Starting Redis migration from Upstash to EC2..."

# Get all keys from Upstash
echo "📋 Getting all keys from Upstash Redis..."
keys=$(redis-cli -u "$UPSTASH_URL" keys "*")

if [ -z "$keys" ]; then
    echo "❌ No keys found in Upstash Redis"
    exit 1
fi

key_count=$(echo "$keys" | wc -l)
echo "📊 Found $key_count keys to migrate"

# Migrate each key with DUMP/RESTORE to preserve TTL
migrated=0
failed=0

echo "$keys" | while read -r key; do
    if [ -n "$key" ]; then
        echo "🔄 Migrating: $key"
        
        # Get TTL first
        ttl=$(redis-cli -u "$UPSTASH_URL" ttl "$key")
        
        # Dump the key from Upstash
        dump_data=$(redis-cli -u "$UPSTASH_URL" dump "$key")
        
        if [ "$dump_data" != "" ] && [ "$dump_data" != "(nil)" ]; then
            # Calculate TTL in milliseconds for RESTORE
            if [ "$ttl" -eq -1 ]; then
                # Key has no expiration
                ttl_ms=0
            elif [ "$ttl" -eq -2 ]; then
                # Key doesn't exist (shouldn't happen)
                echo "⚠️  Key $key doesn't exist, skipping"
                continue
            else
                # Convert seconds to milliseconds
                ttl_ms=$((ttl * 1000))
            fi
            
            # Restore to EC2 Redis
            restore_result=$(redis-cli -h "$EC2_REDIS_HOST" -a "$EC2_REDIS_PASSWORD" restore "$key" $ttl_ms "$dump_data" 2>&1)
            
            if [[ "$restore_result" == "OK" ]]; then
                echo "✅ Successfully migrated: $key (TTL: ${ttl}s)"
                ((migrated++))
            else
                echo "❌ Failed to migrate $key: $restore_result"
                ((failed++))
            fi
        else
            echo "❌ Failed to dump key: $key"
            ((failed++))
        fi
    fi
done

echo ""
echo "🎉 Migration completed!"
echo "✅ Migrated: $migrated keys"
echo "❌ Failed: $failed keys"

# Verify migration
echo ""
echo "🔍 Verifying migration..."
ec2_key_count=$(redis-cli -h "$EC2_REDIS_HOST" -a "$EC2_REDIS_PASSWORD" dbsize)
echo "📊 EC2 Redis now contains: $ec2_key_count keys"

echo ""
echo "🏁 Migration finished!"