def is_port_open(host, port):
    """
    determine whether `host` has the `port` open
    """
    # создает новый сокет
    s = socket.socket()
    try:
        # пытается подключиться к хосту через этот порт
        s.connect((host, port))
        # сделайте таймаут, если хотите немного быстрее (с меньшей точностью)
        # s.settimeout(0.2)
    except:
        # не могу подключиться, порт закрыт
        # return false
        return False
    else:
        # соединение установлено, порт открыт!
        return True