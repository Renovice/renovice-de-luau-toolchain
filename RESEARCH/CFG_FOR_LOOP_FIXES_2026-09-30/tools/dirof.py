import hashlib, sys
m = sys.argv[1]
print(m[:60] if len(m) <= 60 else hashlib.sha1(m.encode()).hexdigest()[:16])
