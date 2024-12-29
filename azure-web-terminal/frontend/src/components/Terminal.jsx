import React, { useEffect, useRef } from 'react';
import { Terminal } from 'xterm';
import 'xterm/css/xterm.css';
import axios from 'axios';

const AzureTerminal = () => {
    const terminalRef = useRef(null);
    const term = useRef(null);

    useEffect(() => {
        term.current = new Terminal();
        term.current.open(terminalRef.current);
        term.current.writeln('Welcome to Azure Web Terminal');

        term.current.onData((input) => {
            axios.post('/api/execute', { command: input })
                .then((res) => {
                    term.current.write(res.data.output + '\r\n');
                })
                .catch(() => term.current.write('Error: Failed to execute command\r\n'));
        });
    }, []);

    return <div ref={terminalRef} style={{ height: '100vh', width: '100%' }}></div>;
};

export default AzureTerminal;
