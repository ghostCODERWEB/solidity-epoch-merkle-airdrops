export async function suite(h) {
  const token = await h.token();
  const c = await h.deploy("EpochDistributor", [token.target, h.addresses[0]]);
  await h.tx(token.approve(c.target, 1000));
  const now = await h.now();
  const root = await c.leaf(1, 0, h.addresses[1], 100);
  await h.tx(c.createEpoch(1, root, 150, now + 100));
  await h.test("invalid proof rejected", () =>
    h.revert(() => c.claim(1, 0, h.addresses[1], 101, [])),
  );
  await h.test("third party can deliver claim", async () => {
    await h.tx(c.connect(h.signers[2]).claim(1, 0, h.addresses[1], 100, []));
    h.eq(await token.balanceOf(h.addresses[1]), 100n);
    h.eq(await c.isClaimed(1, 0), true);
  });
  await h.test("claim replay rejected", () =>
    h.revert(() => c.claim(1, 0, h.addresses[1], 100, [])),
  );
  await h.test("epoch cannot be overwritten", () =>
    h.revert(() => c.createEpoch(1, root, 150, now + 100)),
  );
  await h.test("early reclaim rejected", () => h.revert(() => c.reclaim(1)));
  await h.test("expired epoch refunds remainder", async () => {
    await h.mine(101);
    await h.tx(c.reclaim(1));
    h.eq((await c.epochs(1)).remaining, 0n);
    h.eq(await token.balanceOf(c.target), 0n);
  });
}
