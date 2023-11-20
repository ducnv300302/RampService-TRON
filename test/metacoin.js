if (window.tronLink.ready) {
  const tronweb = tronLink.tronWeb;
  const toAddress = "TRKb2nAnCBfwxnLxgoKJro6VbyA6QmsuXq";
  const activePermissionId = 2;
  const tx = await tronweb.transactionBuilder.sendTrx(
    toAddress, 10,
    { permissionId: activePermissionId}
  ); // step 1
  try {
    const signedTx = await tronweb.trx.multiSign(tx, undefined, activePermissionId); // step 2
    await tronweb.trx.sendRawTransaction(signedTx); // step 3
  } catch (e) {}
}