static int
main (string[] args)
{
    XCB.Connection connection = new XCB.Connection ();
    connection.no_operation_checked_async.begin ((obj, res) => {
        try
        {
            connection.no_operation_checked_async.end (res);
            message ("end");
        }
        catch (XCB.Error err)
        {
            message ("error: %s", err.message);
        }
    });
    connection.flush ();
    connection.process_events ();

    return 0;
}
