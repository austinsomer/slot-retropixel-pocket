import sys, zlib, gzip, io
kern, newpng, out = sys.argv[1], sys.argv[2], sys.argv[3]
d = bytearray(open(kern, "rb").read())
O, LIMIT = 12539608, 3239477
z = zlib.decompressobj(16 + zlib.MAX_WBITS)
cpio = z.decompress(bytes(d[O:O + LIMIT]))
assert len(cpio) == 7576064

def entries(buf):
    p = 0
    while True:
        assert buf[p:p + 6] == b"070701", p
        fs = int(buf[p + 54:p + 62], 16); ns = int(buf[p + 94:p + 102], 16)
        hdr_end = p + 110 + ns; data = (hdr_end + 3) & ~3; nxt = (data + fs + 3) & ~3
        name = buf[p + 110:p + 110 + ns - 1].decode()
        yield p, hdr_end, data, fs, name, nxt
        if name == "TRAILER!!!": return
        p = nxt

png = open(newpng, "rb").read()
rebuilt = bytearray(); found = False
for p, hdr_end, data, fs, name, nxt in entries(cpio):
    hdr = bytearray(cpio[p:hdr_end])
    body = cpio[data:data + fs]
    if name == "splash/splash-640.png":
        found = True; print("old splash", fs, "new", len(png))
        body = png; hdr[54:62] = b"%08X" % len(png)
    rebuilt += hdr
    rebuilt += b"\0" * (((len(rebuilt) + 3) & ~3) - len(rebuilt))
    rebuilt += body
    rebuilt += b"\0" * (((len(rebuilt) + 3) & ~3) - len(rebuilt))
assert found
tail = cpio[len(rebuilt):] if False else b""
# keep the original archive's trailing zero padding to the same total length when possible
rebuilt += b"\0" * max(0, (512 - len(rebuilt) % 512) % 512)
# check every other entry is byte-identical
old = {n: cpio[da:da + f] for _, _, da, f, n, _ in entries(cpio)}
new = {n: bytes(rebuilt[da:da + f]) for _, _, da, f, n, _ in entries(bytes(rebuilt))}
diff = [n for n in old if old[n] != new.get(n)]
print("entries", len(old), "changed", diff)
gz = gzip.compress(bytes(rebuilt), compresslevel=9, mtime=0)
print("gzip", len(gz), "limit", LIMIT, "fits", len(gz) <= LIMIT)
assert len(gz) <= LIMIT
d[O:O + LIMIT] = gz + b"\0" * (LIMIT - len(gz))
open(out, "wb").write(d)
# verify round trip
z2 = zlib.decompressobj(16 + zlib.MAX_WBITS); back = z2.decompress(bytes(d[O:O + LIMIT]))
assert back == bytes(rebuilt); print("verified, kernel size", len(d))
