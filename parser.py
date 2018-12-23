import re
import pyment
def cbpro(ai):
    docs = ai.doc
    params = ai.ref_data
    args = [*params.keys()]
    stage = dict.fromkeys(args, None)
    if docs is None:
        return
    
    arg_trigger = False
    rtn_trigger = False
    prefix = 'Args:'
    postfix = 'Returns:'
    prev_key = ''
    
    for d in [d.strip() for d in docs]:
        
        if d == prefix:
            arg_trigger = True
            continue
        
        if d == postfix:
            rtn_trigger = True
            continue
        
        if rtn_trigger:
            ai.rtn_type = d.split(':')[0]
            break
            
            continue
        if arg_trigger:
            if any([a in d for a in args]):
                arr = d.split(' ', 1)
                key = arr[0]
                
                if '*' in key:
                    key = key.replace('*', '')
                    key = key.replace(':', '')
                    if key in params:
                        params[key].doc = arr[1]
                        stage.pop(key)
                        prev_key = key
                        if len(stage) == 0:
                            arg_trigger = False
                        continue
                
                if key not in params:
                    prev_doc = params[prev_key].doc
                    cont_doc = f"{prev_doc} {d}"
                    params[prev_key].doc = cont_doc
                    continue
                
                td = arr[1].split(':', 1)
                doc = td[1].strip()
                typ = re.sub('[\(\)\[\]]', '', td[0].replace('Optional', ''))
                params[key].typ = typ
                params[key].doc = doc
                stage.pop(key)
                prev_key = key
                if len(stage) == 0:
                    arg_trigger = False
