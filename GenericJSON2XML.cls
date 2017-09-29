/* GenericJSON2XML.cls
 * JSON to XML Parsing controller (null)
 *
 * Authors:
 * Nils Rosen <nr@qkom.de>
 * Dominic Ley <dl@qkom.de>
 */

public class GenericJSON2XML{
  static final JSONToken START_ARRAY=JSONToken.START_ARRAY;
  static final JSONToken END_ARRAY=JSONToken.END_ARRAY;
  static final JSONToken START_OBJECT=JSONToken.START_OBJECT;
  static final JSONToken END_OBJECT=JSONToken.END_OBJECT;

  private String t,v,x; // t=tag, v=value, x=xml
  private JSONParser p; // p=parser
  private JSONToken ct; // ct=current_token
  private Set<JSONToken> token_set;

  public GenericJSON2XML(){
    t=v=x='';
    token_set = new Set<JSONToken>();
    token_set.add(JSONToken.VALUE_STRING);
    token_set.add(JSONToken.VALUE_NULL);
    token_set.add(JSONToken.VALUE_NUMBER_FLOAT);
    token_set.add(JSONToken.VALUE_NUMBER_INT);
    token_set.add(JSONToken.VALUE_TRUE);
    token_set.add(JSONToken.VALUE_FALSE);
  }

  public String parse(String input, boolean return64){
    p = JSON.createParser(input);
    while(p.nextToken()!=null){
      ct = p.getCurrentToken();
      if(ct==START_ARRAY) this.parse_token('array');
      else if(ct==START_OBJECT) this.parse_token('item');
      else if(this.token_set.contains(ct)){
        t = p.getCurrentName();
        v = p.getText();
        x += ('<'+t+'>'+(v!='null'?v:'')+'</'+t+'>');
      }
    }
    return (return64)?EncodingUtil.base64Encode(Blob.valueOf(x)):x;
  }

  private void parse_token(String type){
    t = p.getCurrentName();
    x += (t==null)?'<'+type+'>':('<'+t+'>');
    while(p.nextToken()!=null){
      ct = p.getCurrentToken();
      if(this.token_set.contains(ct)){
        t = p.getCurrentName();
        v = p.getText();
        x += ('<'+t+'>'+(v!='null'?v:'')+'</'+t+'>');
      }
      else if(ct==START_ARRAY) this.parse_token('array');
      else if(ct==START_OBJECT) this.parse_token('item');
      else if(ct==END_OBJECT || ct==END_ARRAY){
        t = p.getCurrentName();
        x += ((t==null)?'</'+type+'>':'</'+t+'>');
        return;
      }
    }
  }
}
